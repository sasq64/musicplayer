#pragma once
#include <memory>

namespace utils {

// For temporarily use a unique_ptr as a raw ptr
template <typename T, typename A> struct RawPtr
{
    std::unique_ptr<T, A>& uptr;
    T* ptr;

    RawPtr(std::unique_ptr<T, A>& uptr) : uptr(uptr), ptr(uptr.get()) {}

    RawPtr(std::unique_ptr<T, A>&& uptr) : uptr(uptr), ptr(uptr.get())
    {
        uptr.reset(nullptr);
    }

    ~RawPtr() { uptr.reset(ptr); }

    operator T*() { return ptr; }

    T** operator&() { return &ptr; }
};

template <typename T, typename A>
RawPtr<T, A> raw_ptr(std::unique_ptr<T, A>& uptr)
{
    return RawPtr<T, A>(uptr);
}

// Can hold smart_ptr or raw pointer
template <typename T> struct Pointer
{
    Pointer(std::shared_ptr<T> p) : sptr(p), ptr(p.get()) {}
    Pointer(T* p) : ptr(p) {}
    T* operator->() const { return ptr; }
    T* get() { return ptr; }

private:
    std::shared_ptr<T> sptr;
    T* ptr = nullptr;
};
} // namespace utils
