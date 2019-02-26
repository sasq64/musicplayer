#pragma once

#include "log.h"
#include "utils.h"

#include <cstdlib>
#include <mutex>
#include <condition_variable>
#include <thread>
#include <vector>

namespace utils {

class Jobs
{
public:
	using JobFunction = void (*)(void*, int);

	int coreCount;

	struct Job {
		Job(JobFunction fn = nullptr, void* data = nullptr, int arg = 0)
		    : fn(fn), data(data), arg(arg)
		{
		}
		Job(JobFunction fn, std::shared_ptr<void> data, int arg = 0) : fn(fn), data(data), arg(arg)
		{
		}
		JobFunction fn;
		utils::Pointer<void> data;
		int arg;
	};

	struct Core {
		Core() : jobSize(0x300), jobs(jobSize), bottom(0), top(0) {}

		Core(Core&& core) = default;

		int jobSize;
		bool quit = false;
		std::vector<Job> jobs;
		std::atomic<unsigned> bottom;
		std::atomic<unsigned> top;
		int id;
		std::thread t;
		std::mutex m;
		std::condition_variable cv;
		std::atomic<bool> waiting;

		unsigned add(const Job& job)
		{
			std::unique_lock<std::mutex> lock(m);
			while (bottom - top >= (unsigned)jobSize) {
				// NOTE: If `top` writer does not hold this lock, it may wait more then necessary. BUT that is OK
				// since this is just a safe guard for when the job queue is full.
				lock.unlock();
				std::this_thread::sleep_for(std::chrono::microseconds(100));
				lock.lock();
			}
			jobs[bottom % jobSize] = job;
			bottom++;
			return (bottom - 1);
		}

		Job* get()
		{
			if (top >= bottom)
				return nullptr;

			auto* job = &jobs[top % jobSize];
			return job;
		}
	};

	std::vector<Core> cores;

	Jobs()
	{
		coreCount = std::thread::hardware_concurrency() - 1;
		cores = std::vector<Core>(coreCount);
		// Log("Creating %d cores", coreCount);
		for (int i = 0; i < coreCount; i++) {
			cores[i].id = i;
			Run(cores[i]);
		}
	}

	~Jobs()
	{
		for (Core& core : cores) {
			std::unique_lock<std::mutex> lock(core.m);
			core.bottom = core.top.load();
			core.quit = true;
			core.cv.notify_all();
		}
		for (Core& core : cores)
			core.t.join();
	}

	void Run(Core& core)
	{
		using namespace std::chrono_literals;
		core.t = std::thread([&core] {
			Job* job;
			while (!core.quit) {
				{
					std::unique_lock<std::mutex> lock(core.m);
					core.waiting = true;
					core.cv.wait(lock);
					core.waiting = false;
					job = core.get();
				}
				while (job) {
					// printf("%p %p %d", job, job->fn, core.top);
					job->fn(job->data.get(), job->arg);
					job->data = nullptr;
					core.top++;
					// NOTE: This lock can be avoided. Only needed for reading the Job, could
					// be replaced by a barrier.
					std::unique_lock<std::mutex> lock(core.m);
					job = core.get();
				}
			}
			// printf("Thread %d ending\n", core.id);
		});
	}

	// Hold a call to a member function int CLASS returning void and taking ARG as a single parameter
	template <typename CLASS, typename ARG> struct CallHolder;

	template <typename CLASS> struct CallHolder<CLASS, int> {
		CallHolder(void (CLASS::*fn)(int), CLASS* obj) : fn(fn), obj(obj) {}
		void (CLASS::*fn)(int);
		CLASS* obj;
		void call(const int &arg) {
			(obj->*(fn))(arg);
		}
	};

	template <typename CLASS> struct CallHolder<CLASS, void> {
		CallHolder(void (CLASS::*fn)(), CLASS* obj) : fn(fn), obj(obj) {}
		void (CLASS::*fn)();
		CLASS* obj;
		void call(const int&) {
			(obj->*(fn))();
		}
	};

	unsigned addJob(int cn, const Job& job)
	{
		if (cn < 0)
			cn = coreCount + cn;

		auto& core = cores[cn % coreCount];
		unsigned j = core.add(job);
		core.cv.notify_all();
		return j | ((cn % coreCount) << 24);
	}

	template <typename CLASS>
	unsigned Add(int cn, void (CLASS::*fn)(int), CLASS* data, int arg)
	{
		Job job(
		    [](void* data, int arg) {
			    auto* holder = reinterpret_cast<CallHolder<CLASS,int>*>(data);
				holder->call(arg);
			    delete holder;
		    },
		    (void*)(new CallHolder<CLASS,int>(fn, data)), arg);
		return addJob(cn, job);
	}

	template <typename CLASS>
	unsigned Add(int cn, void (CLASS::*fn)(), CLASS* ptr)
	{
		Job job(
		    [](void* data, int) {
			    auto* holder = reinterpret_cast<CallHolder<CLASS,void>*>(data);
				holder->call(0);
			    delete holder;
		    },
		    (void*)(new CallHolder<CLASS,void>(fn, ptr)), 0);
		return addJob(cn, job);
	}

	template <typename FN>
	unsigned Add(int cn, const FN& fn, std::shared_ptr<void> data = nullptr, int arg = 0)
	{
		Job job((JobFunction)fn, data, arg);
		return addJob(cn, job);
	}

	template <typename FN> unsigned Add(int cn, const FN& fn, void* data = nullptr, int arg = 0)
	{
		Job job((JobFunction)fn, data, arg);
		return addJob(cn, job);
	}

	void Wait(unsigned j)
	{
		int c = j >> 24;
		j &= 0xffffff;
		auto& core = cores[c];
		while (j >= core.top)
			std::this_thread::sleep_for(std::chrono::microseconds(100));
	}

	template <typename FN> unsigned Add(const FN& fn, void* data = nullptr, int arg = 0)
	{
		Job job((JobFunction)fn, data, arg);
		for (int i=0; i<coreCount; i++) {
			if (cores[i].waiting) {
				return addJob(i, job);
			}
		}
		return addJob(rand(), job);
	}

	void Wait()
	{
		for (auto& core : cores) {
			while (core.top < core.bottom) {
				std::this_thread::sleep_for(std::chrono::milliseconds(50));
				core.m.lock();
				core.m.unlock();
				core.cv.notify_all();
			}
		}
	}

	static Jobs& getInstance()
	{
		static Jobs jobs;
		return jobs;
	}
};

} // namespace utils
