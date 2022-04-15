#pragma once

#include <algorithm>
#include <functional>
#include <list>
#include <tuple>

template <typename T, typename ID = int> struct LRU
{
    int maxSize;
    std::list<std::pair<ID, T>> elements;

    LRU(int size) : maxSize(size) {}

    void clear() { elements.clear(); }

    void insert(const ID& id, const T& t)
    {
        if (elements.size() == maxSize)
            elements.pop_back();
        elements.push_front(std::make_pair(id, t));
    }

    T get(const ID& id, std::function<T()> create)
    {
        auto it = find(id);
        if (it != elements.end()) {
            elements.splice(elements.begin(), elements, it);
            return it->second;
        }
        insert(id, create());
        return elements.begin()->second;
    }

    T get(const ID& id, std::function<T(const ID&)> create)
    {
        auto it = find(id);
        if (it != elements.end()) {
            elements.splice(elements.begin(), elements, it);
            return it->second;
        }
        insert(id, create(id));
        return elements.begin()->second;
    }
    /*
        template <typename FN> T get(const ID &id, FN create) {
            auto it = find(id);
            if (it != elements.end()) {
                elements.splice(elements.begin(), elements, it);
                return it->second;
            }
            insert(id, create(id));
            return elements.begin()->second;

        }
    */
    auto find(const ID& id)
    {
        return std::find_if(
            elements.begin(), elements.end(),
            [&id](const auto& a) -> bool { return id == a.first; });
    }

    T get(const ID& id)
    {
        auto it = find(id);
        if (it == elements.end())
            throw std::exception();
        // TODO: std::rotate
        elements.splice(elements.begin(), elements, it);
        return it->second;
    }

    bool isCached(const ID& id) { return find(id) != elements.end(); }
};

