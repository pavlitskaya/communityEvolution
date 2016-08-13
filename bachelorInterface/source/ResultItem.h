#pragma once

#include <unordered_map>
#include <cereal/types/unordered_map.hpp>
#include <cereal/types/vector.hpp>
#include <cereal/archives/json.hpp>

#include <general_defines.h>

class ResultItem
{
    public:
        ResultItem(std::string filename) : m_filename(filename) {}
        ResultItem() {}

        template<class Archive>
        void serialize(Archive& ar)
        {
            ar(CEREAL_NVP(snapshots));
        }

        void put_value(std::string name, int value)
        {
            m_metadata.insert(std::pair<std::string, int>(name, value));
        }

        void add_snapshots(std::unordered_map<std::string, std::vector<snapshot_t>> snapshots)
        {
            this->snapshots.push_back(snapshots);
        }

    private:
        std::string m_filename;
        std::unordered_map<std::string, int> m_metadata;
        std::vector<std::unordered_map<std::string, std::vector<snapshot_t>>> snapshots;
};

