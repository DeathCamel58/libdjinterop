/*
    This file is part of libdjinterop.

    libdjinterop is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    libdjinterop is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with libdjinterop.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma once

#include <cstdint>
#include <vector>

#include <djinterop/engine/v2/overview_waveform_data_blob.hpp>
#include <djinterop/optional.hpp>
#include <djinterop/performance_data.hpp>

namespace djinterop::engine::v2::convert
{
namespace read
{
inline djinterop::waveform_entry waveform_entry(
    const overview_waveform_point& p)
{
    return djinterop::waveform_entry{
        djinterop::waveform_point{p.low_value},
        djinterop::waveform_point{p.mid_value},
        djinterop::waveform_point{p.high_value},
    };
}

inline std::vector<djinterop::waveform_entry> waveform(
    const overview_waveform_data_blob& w)
{
    std::vector<djinterop::waveform_entry> results{};
    results.reserve(w.waveform_points.size());

    for (auto&& p : w.waveform_points)
        results.push_back(waveform_entry(p));

    return results;
}
}  // namespace read

namespace write
{
inline overview_waveform_point waveform_entry(
    const djinterop::waveform_entry& p)
{
    return overview_waveform_point{p.low.value, p.mid.value, p.high.value};
}

inline overview_waveform_data_blob waveform(
    const std::vector<djinterop::waveform_entry>& w,
    stdx::optional<sampling_info> sampling)
{
    overview_waveform_data_blob result;
    result.waveform_points.reserve(w.size());

    result.samples_per_waveform_point =
        (sampling && sampling->sample_count != 0)
            ? static_cast<double>(sampling->sample_count) / w.size()
            : 0;

    uint8_t max_low = 0;
    uint8_t max_mid = 0;
    uint8_t max_high = 0;
    for (auto&& entry : w)
    {
        max_low = std::max(max_low, entry.low.value);
        max_mid = std::max(max_mid, entry.mid.value);
        max_high = std::max(max_high, entry.high.value);
        result.waveform_points.push_back(waveform_entry(entry));
    }

    result.maximum_point = overview_waveform_point{max_low, max_mid, max_high};
    return result;
}
}  // namespace write
}  // namespace djinterop::engine::v2::convert
