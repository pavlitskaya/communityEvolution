#pragma once

#include <unordered_map>
#include <cereal/types/unordered_map.hpp>
#include <cereal/archives/json.hpp>

#include <general_defines.h>

class ResultItem
{
    public:
        template<class Archive>
        void serialize(Archive& ar)
        {
            ar(CEREAL_NVP(m_metadata), CEREAL_NVP(m_snapshots));
        }

        void put_value(std::string name, int value)
        {
            m_metadata.insert(std::pair<std::string, int>(name, value));
        }

        void set_snapshots(std::vector<snapshot_t>& snapshots)
        {
            m_snapshots = snapshots;
        }

    private:
        std::unordered_map<std::string, int> m_metadata;
        std::vector<snapshot_t> m_snapshots;
};

