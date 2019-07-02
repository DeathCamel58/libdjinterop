#include <djinterop/djinterop.hpp>
#include <djinterop/enginelibrary/el_crate_impl.hpp>
#include <djinterop/enginelibrary/el_database_impl.hpp>
#include <djinterop/enginelibrary/el_storage.hpp>
#include <djinterop/enginelibrary/el_track_impl.hpp>
#include <djinterop/enginelibrary/schema.hpp>
#include <djinterop/impl/util.hpp>

namespace djinterop
{
namespace enginelibrary
{
using djinterop::crate;
using djinterop::track;

el_database_impl::el_database_impl(std::string directory)
    : storage_{std::make_shared<el_storage>(std::move(directory))}
{
}

el_database_impl::el_database_impl(std::shared_ptr<el_storage> storage)
    : storage_{std::move(storage)}
{
}

boost::optional<crate> el_database_impl::crate_by_id(int64_t id)
{
    boost::optional<crate> cr;
    storage_->music_db << "SELECT COUNT(*) FROM Crate WHERE id = ?" << id >>
        [&](int64_t count) {
            if (count == 1)
            {
                cr = crate{std::make_shared<el_crate_impl>(storage_, id)};
            }
            else if (count > 1)
            {
                throw crate_database_inconsistency{
                    "More than one crate with the same ID", id};
            }
        };
    return cr;
}

std::vector<crate> el_database_impl::crates()
{
    std::vector<crate> results;
    storage_->music_db << "SELECT id FROM Crate ORDER BY id" >>
        [&](int64_t id) {
            results.push_back(
                crate{std::make_shared<el_crate_impl>(storage_, id)});
        };
    return results;
}

std::vector<crate> el_database_impl::crates_by_name(boost::string_view name)
{
    std::vector<crate> results;
    storage_->music_db << "SELECT id FROM Crate WHERE title = ? ORDER BY id"
                       << name.data() >>
        [&](int64_t id) {
            results.push_back(
                crate{std::make_shared<el_crate_impl>(storage_, id)});
        };
    return results;
}

crate el_database_impl::create_crate(boost::string_view name)
{
    storage_->music_db << "BEGIN";

    storage_->music_db << "INSERT INTO Crate (title, path) VALUES (?, ?)"
                       << name.data() << std::string{name} + ';';

    int64_t id = storage_->music_db.last_insert_rowid();

    storage_->music_db << "INSERT INTO CrateParentList (crateOriginId, "
                          "crateParentId) VALUES (?, ?)"
                       << id << id;

    storage_->music_db << "COMMIT";

    return crate{std::make_shared<el_crate_impl>(storage_, id)};
}

track el_database_impl::create_track(boost::string_view relative_path)
{
    // TODO (haslersn): Should it be allowed to create two tracks with the same
    // `relative_path`?

    auto filename = get_filename(relative_path);

    storage_->music_db << "BEGIN";

    // Insert a new entry in the track table
    storage_->music_db << "INSERT INTO Track (path, filename, trackType, "
                          "isExternalTrack, idAlbumArt) VALUES (?,?,?,?,?)"
                       << relative_path.data()   //
                       << std::string{filename}  //
                       << 1                      // trackType
                       << 0                      // isExternalTrack
                       << 1;                     // idAlbumArt

    auto id = storage_->music_db.last_insert_rowid();

    if (version() >= version_1_7_1)
    {
        storage_->music_db << "UPDATE Track SET pdbImportKey = 0 WHERE id = ?"
                           << id;
    }

    {
        auto extension = get_file_extension(filename);
        auto metadata_str_inserter =
            storage_->music_db
            << "REPLACE INTO MetaData (id, type, text) VALUES (?, ?, ?)";
        for (int64_t type : {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 15, 16})
        {
            boost::optional<std::string> text;
            switch (type)
            {
                case 10:
                    // duration in MM:SS
                    // TODO (haslersn)
                    break;
                case 13:
                    // extension
                    if (extension)
                    {
                        text = extension->to_string();
                    }
                    break;
                case 15:
                case 16:
                    // Always 1 to our knowledge
                    text = "1";
                    break;
            }
            metadata_str_inserter << id << type << text;
            metadata_str_inserter++;
        }
    }

    {
        auto metadata_int_inserter = storage_->music_db
                                     << "REPLACE INTO MetaDataInteger (id, "
                                        "type, value) VALUES (?, ?, ?)";
        for (int64_t type = 1; type <= 11 /* 12 */; ++type)
        {
            boost::optional<int64_t> value;
            switch (type)
            {
                case 5: value = 0; break;
                case 11:
                    // case 12:
                    value = 1;
                    break;
            }
            metadata_int_inserter << id << type << value;
            metadata_int_inserter++;
        }
    }

    storage_->music_db << "COMMIT";

    return track{std::make_shared<el_track_impl>(storage_, id)};
}

std::string el_database_impl::directory()
{
    return storage_->directory;
}

bool el_database_impl::is_supported()
{
    return djinterop::enginelibrary::is_supported(version());
}

void el_database_impl::verify()
{
    // Verify music schema
    verify_music_schema(storage_->music_db);

    // Verify performance schema
    verify_performance_schema(storage_->perfdata_db);
}

std::string el_database_impl::music_db_path()
{
    return storage_->music_db_path;
}

std::string el_database_impl::perfdata_db_path()
{
    return storage_->perfdata_db_path;
}

void el_database_impl::remove_crate(crate cr)
{
    storage_->music_db << "DELETE FROM Crate WHERE id = ?" << cr.id();
}

void el_database_impl::remove_track(track tr)
{
    storage_->music_db << "DELETE FROM Track WHERE id = ?" << tr.id();
    // All other references to the track should automatically be cleared by
    // "ON DELETE CASCADE"
}

std::vector<crate> el_database_impl::root_crates()
{
    std::vector<crate> results;
    storage_->music_db
            << "SELECT crateOriginId FROM CrateParentList WHERE crateParentId "
               "= crateOriginId ORDER BY crateOriginId" >>
        [&](int64_t id) {
            results.push_back(
                crate{std::make_shared<el_crate_impl>(storage_, id)});
        };
    return results;
}

boost::optional<track> el_database_impl::track_by_id(int64_t id)
{
    boost::optional<track> tr;
    storage_->music_db << "SELECT COUNT(*) FROM Track WHERE id = ?" << id >>
        [&](int64_t count) {
            if (count == 1)
            {
                tr = track{std::make_shared<el_track_impl>(storage_, id)};
            }
            else if (count > 1)
            {
                throw track_database_inconsistency{
                    "More than one track with the same ID", id};
            }
        };
    return tr;
}

std::vector<track> el_database_impl::tracks()
{
    std::vector<track> results;
    storage_->music_db << "SELECT id FROM Track ORDER BY id" >>
        [&](int64_t id) {
            results.push_back(
                track{std::make_shared<el_track_impl>(storage_, id)});
        };
    return results;
}

std::vector<track> el_database_impl::tracks_by_relative_path(
    boost::string_view relative_path)
{
    std::vector<track> results;
    storage_->music_db << "SELECT id FROM Track WHERE path = ? ORDER BY id"
                       << relative_path.data() >>
        [&](int64_t id) {
            results.push_back(
                track{std::make_shared<el_track_impl>(storage_, id)});
        };
    return results;
}

std::string el_database_impl::uuid()
{
    std::string uuid;
    storage_->music_db << "SELECT uuid FROM Information" >> uuid;
    return uuid;
}

semantic_version el_database_impl::version()
{
    semantic_version version;
    storage_->music_db << "SELECT schemaVersionMajor, schemaVersionMinor, "
                          "schemaVersionPatch FROM Information" >>
        std::tie(version.maj, version.min, version.pat);
    return version;
}

}  // namespace enginelibrary
}  // namespace djinterop
