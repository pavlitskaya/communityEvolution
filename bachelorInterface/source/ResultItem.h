#pragma once

#include <unordered_map>
#include <cereal/types/unordered_map.hpp>
#include <cereal/archives/json.hpp>

class ResultItem
{
    public:
        template<class Archive>
        void serialize(Archive& ar)
        {
            ar(CEREAL_NVP(m_metadata));
        }

        void put_value(std::string name, int value)
        {
            m_metadata.insert(std::pair<std::string, int>(name, value));
        }

    private:
        // Metadata
        std::unordered_map<std::string, int> m_metadata;
};

