PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE Track ( [id] INTEGER, [playOrder] INTEGER, [length] INTEGER, [lengthCalculated] INTEGER, [bpm] INTEGER, [year] INTEGER, [path] TEXT, [filename] TEXT, [bitrate] INTEGER, [bpmAnalyzed] REAL, [trackType] INTEGER, [isExternalTrack] NUMERIC, [uuidOfExternalDatabase] TEXT, [idTrackInExternalDatabase] INTEGER, [idAlbumArt] INTEGER, [pdbImportKey] INTEGER, PRIMARY KEY ( [id] ) , FOREIGN KEY ( [idAlbumArt] ) REFERENCES AlbumArt ( [id] )  ON DELETE RESTRICT);
CREATE TABLE Information ( [id] INTEGER, [uuid] TEXT, [schemaVersionMajor] INTEGER, [schemaVersionMinor] INTEGER, [schemaVersionPatch] INTEGER, [currentPlayedIndiciator] INTEGER, [lastRekordBoxLibraryImportReadCounter] INTEGER, PRIMARY KEY ( [id] ) );
INSERT INTO Information VALUES(1,'a3be0d5e-b1f8-4933-9e01-e048443141f6',1,9,1,10277856763400,0);
CREATE TABLE MetaData ( [id] INTEGER, [type] INTEGER, [text] TEXT, PRIMARY KEY ( [id], [type] ) , FOREIGN KEY ( [id] ) REFERENCES Track ( [id] )  ON DELETE CASCADE);
CREATE TABLE MetaDataInteger ( [id] INTEGER, [type] INTEGER, [value] INTEGER, PRIMARY KEY ( [id], [type] ) , FOREIGN KEY ( [id] ) REFERENCES Track ( [id] )  ON DELETE CASCADE);
CREATE TABLE AlbumArt ( [id] INTEGER, [hash] TEXT, [albumArt] BLOB, PRIMARY KEY ( [id] ) );
CREATE TABLE CopiedTrack ( [trackId] INTEGER, [uuidOfSourceDatabase] TEXT, [idOfTrackInSourceDatabase] INTEGER, PRIMARY KEY ( [trackId] ) , FOREIGN KEY ( [trackId] ) REFERENCES Track ( [id] )  ON DELETE CASCADE);
CREATE TABLE List ( [id] INTEGER, [type] INTEGER, [title] TEXT, [path] TEXT, [isFolder] NUMERIC, PRIMARY KEY ( [id], [type] ) );
INSERT INTO List VALUES(1,3,'Prepare','Prepare;',0);
CREATE TABLE ListTrackList ( [id] INTEGER, [listId] INTEGER, [listType] INTEGER, [trackId] INTEGER, [trackIdInOriginDatabase] INTEGER, [databaseUuid] TEXT, [trackNumber] INTEGER, PRIMARY KEY ( [id] ) , FOREIGN KEY ( [listId], [listType] ) REFERENCES List ( [id], [type] )  ON DELETE CASCADE, FOREIGN KEY ( [trackId] ) REFERENCES Track ( [id] )  ON DELETE CASCADE);
CREATE TABLE ListHierarchy ( [listId] INTEGER, [listType] INTEGER, [listIdChild] INTEGER, [listTypeChild] INTEGER, FOREIGN KEY ( [listId], [listType] ) REFERENCES List ( [id], [type] )  ON DELETE CASCADE, FOREIGN KEY ( [listIdChild], [listTypeChild] ) REFERENCES List ( [id], [type] )  ON DELETE CASCADE);
CREATE TABLE ListParentList ( [listOriginId] INTEGER, [listOriginType] INTEGER, [listParentId] INTEGER, [listParentType] INTEGER, FOREIGN KEY ( [listOriginId], [listOriginType] ) REFERENCES List ( [id], [type] )  ON DELETE CASCADE, FOREIGN KEY ( [listParentId], [listParentType] ) REFERENCES List ( [id], [type] )  ON DELETE CASCADE);
CREATE INDEX index_Track_id ON Track ( id );
CREATE INDEX index_Track_path ON Track ( path );
CREATE INDEX index_Track_filename ON Track ( filename );
CREATE INDEX index_Track_isExternalTrack ON Track ( isExternalTrack );
CREATE INDEX index_Track_uuidOfExternalDatabase ON Track ( uuidOfExternalDatabase );
CREATE INDEX index_Track_idTrackInExternalDatabase ON Track ( idTrackInExternalDatabase );
CREATE INDEX index_Track_idAlbumArt ON Track ( idAlbumArt );
CREATE INDEX index_Information_id ON Information ( id );
CREATE INDEX index_MetaData_id ON MetaData ( id );
CREATE INDEX index_MetaData_type ON MetaData ( type );
CREATE INDEX index_MetaData_text ON MetaData ( text );
CREATE INDEX index_MetaDataInteger_id ON MetaDataInteger ( id );
CREATE INDEX index_MetaDataInteger_type ON MetaDataInteger ( type );
CREATE INDEX index_MetaDataInteger_value ON MetaDataInteger ( value );
CREATE INDEX index_AlbumArt_id ON AlbumArt ( id );
CREATE INDEX index_AlbumArt_hash ON AlbumArt ( hash );
CREATE INDEX index_CopiedTrack_trackId ON CopiedTrack ( trackId );
CREATE INDEX index_List_id ON List ( id );
CREATE INDEX index_List_type ON List ( type );
CREATE INDEX index_List_path ON List ( path );
CREATE VIEW Playlist AS SELECT id, title FROM List WHERE type = 1;
CREATE VIEW Historylist AS SELECT id, title FROM List WHERE type = 2;
CREATE VIEW Preparelist AS SELECT id, title FROM List WHERE type = 3;
CREATE VIEW Crate AS SELECT id AS id, title AS title, path AS path FROM List WHERE type = 4;
CREATE TRIGGER trigger_delete_Playlist INSTEAD OF DELETE ON Playlist FOR EACH ROW BEGIN   DELETE FROM List WHERE type = 1 AND OLD.id = id AND OLD.title = title; END;
CREATE TRIGGER trigger_update_Playlist INSTEAD OF UPDATE ON Playlist FOR EACH ROW BEGIN   UPDATE List SET id = NEW.id, title = NEW.title   WHERE  id = OLD.id AND title = OLD.title   ;  END;
CREATE TRIGGER trigger_insert_Playlist INSTEAD OF INSERT ON Playlist FOR EACH ROW BEGIN   INSERT INTO List ( id, type, title, path, isFolder )    VALUES ( NEW.id, 1, NEW.title, NEW.title || ";", 0 ) ;  INSERT INTO ListParentList ( listOriginId, listOriginType, listParentId, listParentType )   VALUES ( NEW.id, 1,            NEW.id, 1 ) ; END;
CREATE TRIGGER trigger_delete_Historylist INSTEAD OF DELETE ON Historylist FOR EACH ROW BEGIN   DELETE FROM List WHERE type = 2 AND OLD.id = id AND OLD.title = title; END;
CREATE TRIGGER trigger_update_Historylist INSTEAD OF UPDATE ON Historylist FOR EACH ROW BEGIN   UPDATE List SET id = NEW.id, title = NEW.title   WHERE  id = OLD.id AND title = OLD.title   ;  END;
CREATE TRIGGER trigger_insert_Historylist INSTEAD OF INSERT ON Historylist FOR EACH ROW BEGIN   INSERT INTO List ( id, type, title, path, isFolder )    VALUES ( NEW.id, 2, NEW.title, NEW.title || ";", 0 ) ;  INSERT INTO ListParentList ( listOriginId, listOriginType, listParentId, listParentType )   VALUES ( NEW.id, 2,            NEW.id, 2 ) ; END;
CREATE TRIGGER trigger_delete_Preparelist INSTEAD OF DELETE ON Preparelist FOR EACH ROW BEGIN   DELETE FROM List WHERE type = 3 AND OLD.id = id AND OLD.title = title; END;
CREATE TRIGGER trigger_update_Preparelist INSTEAD OF UPDATE ON Preparelist FOR EACH ROW BEGIN   UPDATE List SET id = NEW.id, title = NEW.title   WHERE  id = OLD.id AND title = OLD.title   ;  END;
CREATE TRIGGER trigger_insert_Preparelist INSTEAD OF INSERT ON Preparelist FOR EACH ROW BEGIN   INSERT INTO List ( id, type, title, path, isFolder )    VALUES ( NEW.id, 3, NEW.title, NEW.title || ";", 0 ) ;  INSERT INTO ListParentList ( listOriginId, listOriginType, listParentId, listParentType )   VALUES ( NEW.id, 3,            NEW.id, 3 ) ; END;
CREATE TRIGGER trigger_delete_Crate INSTEAD OF DELETE ON Crate FOR EACH ROW BEGIN   DELETE FROM List WHERE type = 4 AND OLD.id = id AND OLD.title = title AND OLD.path = path; END;
CREATE TRIGGER trigger_update_Crate INSTEAD OF UPDATE ON Crate FOR EACH ROW BEGIN   UPDATE List SET id = NEW.id, title = NEW.title, path = NEW.path   WHERE  id = OLD.id AND title = OLD.title AND path = OLD.path   ;  END;
CREATE TRIGGER trigger_insert_Crate INSTEAD OF INSERT ON Crate FOR EACH ROW BEGIN   INSERT INTO List ( id, type, title, path, isFolder )    VALUES ( NEW.id, 4, NEW.title, NEW.path, 0 ) ; END;
CREATE INDEX index_ListTrackList_listId ON ListTrackList ( listId );
CREATE INDEX index_ListTrackList_listType ON ListTrackList ( listType );
CREATE INDEX index_ListTrackList_trackId ON ListTrackList ( trackId );
CREATE VIEW PlaylistTrackList AS SELECT listId AS playlistId, trackId, trackIdInOriginDatabase, databaseUuid, trackNumber FROM ListTrackList AS ltl INNER JOIN List AS l ON l.id = ltl.listId AND l.type = ltl.listType WHERE ltl.listType = 1;
CREATE VIEW HistorylistTrackList AS SELECT listId AS historylistId, trackId, trackIdInOriginDatabase, databaseUuid, 0 AS date FROM ListTrackList AS ltl INNER JOIN List AS l ON l.id = ltl.listId AND l.type = ltl.listType WHERE ltl.listType = 2;
CREATE VIEW PreparelistTrackList AS SELECT listId AS playlistId, trackId, trackIdInOriginDatabase, databaseUuid, trackNumber FROM ListTrackList AS ltl INNER JOIN List AS l ON l.id = ltl.listId AND l.type = ltl.listType WHERE ltl.listType = 3;
CREATE VIEW CrateTrackList AS SELECT listId AS crateId, trackId AS trackId FROM ListTrackList AS ltl INNER JOIN List AS l ON l.id = ltl.listId AND l.type = ltl.listType WHERE ltl.listType = 4;
CREATE TRIGGER trigger_delete_PlaylistTrackList INSTEAD OF DELETE ON PlaylistTrackList FOR EACH ROW BEGIN   DELETE FROM ListTrackList WHERE listType = 1 AND OLD.playlistId = listId AND OLD.trackId = trackId AND OLD.trackIdInOriginDatabase = trackIdInOriginDatabase AND OLD.databaseUuid = databaseUuid AND OLD.trackNumber = trackNumber; END;
CREATE TRIGGER trigger_update_PlaylistTrackList INSTEAD OF UPDATE ON PlaylistTrackList FOR EACH ROW BEGIN   UPDATE ListTrackList SET listId = NEW.playlistId , trackId = NEW.trackId , trackIdInOriginDatabase = NEW.trackIdInOriginDatabase , databaseUuid = NEW.databaseUuid , trackNumber = NEW.trackNumber   WHERE listType = 1 AND OLD.playlistId = listId AND OLD.trackId = trackId AND OLD.trackIdInOriginDatabase = trackIdInOriginDatabase AND OLD.databaseUuid = databaseUuid AND OLD.trackNumber = trackNumber ; END;
CREATE TRIGGER trigger_insert_PlaylistTrackList INSTEAD OF INSERT ON PlaylistTrackList FOR EACH ROW BEGIN   INSERT INTO ListTrackList ( listId, listType, trackId, trackIdInOriginDatabase, databaseUuid, trackNumber )                     SELECT NEW.playlistId, 1, NEW.trackId, NEW.trackIdInOriginDatabase, NEW.databaseUuid, NEW.trackNumber                    FROM List AS l WHERE l.id = NEW.playlistId AND l.type = 1 AND l.isFolder = 0 ; END;
CREATE TRIGGER trigger_delete_HistorylistTrackList INSTEAD OF DELETE ON HistorylistTrackList FOR EACH ROW BEGIN   DELETE FROM ListTrackList WHERE listType = 2 AND OLD.historylistId = listId AND OLD.trackId = trackId AND OLD.trackIdInOriginDatabase = trackIdInOriginDatabase AND OLD.databaseUuid = databaseUuid; END;
CREATE TRIGGER trigger_update_HistorylistTrackList INSTEAD OF UPDATE ON HistorylistTrackList FOR EACH ROW BEGIN   UPDATE ListTrackList SET listId = NEW.historylistId , trackId = NEW.trackId , trackIdInOriginDatabase = NEW.trackIdInOriginDatabase , databaseUuid = NEW.databaseUuid   WHERE listType = 2 AND OLD.historylistId = listId AND OLD.trackId = trackId AND OLD.trackIdInOriginDatabase = trackIdInOriginDatabase AND OLD.databaseUuid = databaseUuid ; END;
CREATE TRIGGER trigger_insert_HistorylistTrackList INSTEAD OF INSERT ON HistorylistTrackList FOR EACH ROW BEGIN   INSERT INTO ListTrackList ( listId, listType, trackId, trackIdInOriginDatabase, databaseUuid, trackNumber )                     SELECT NEW.historylistId, 2, NEW.trackId, NEW.trackIdInOriginDatabase, NEW.databaseUuid, 0                    FROM List AS l WHERE l.id = NEW.historylistId AND l.type = 2 AND l.isFolder = 0 ; END;
CREATE TRIGGER trigger_delete_PreparelistTrackList INSTEAD OF DELETE ON PreparelistTrackList FOR EACH ROW BEGIN   DELETE FROM ListTrackList WHERE listType = 3 AND OLD.playlistId = listId AND OLD.trackId = trackId AND OLD.trackIdInOriginDatabase = trackIdInOriginDatabase AND OLD.databaseUuid = databaseUuid AND OLD.trackNumber = trackNumber; END;
CREATE TRIGGER trigger_update_PreparelistTrackList INSTEAD OF UPDATE ON PreparelistTrackList FOR EACH ROW BEGIN   UPDATE ListTrackList SET listId = NEW.playlistId , trackId = NEW.trackId , trackIdInOriginDatabase = NEW.trackIdInOriginDatabase , databaseUuid = NEW.databaseUuid , trackNumber = NEW.trackNumber   WHERE listType = 3 AND OLD.playlistId = listId AND OLD.trackId = trackId AND OLD.trackIdInOriginDatabase = trackIdInOriginDatabase AND OLD.databaseUuid = databaseUuid AND OLD.trackNumber = trackNumber ; END;
CREATE TRIGGER trigger_insert_PreparelistTrackList INSTEAD OF INSERT ON PreparelistTrackList FOR EACH ROW BEGIN   INSERT INTO ListTrackList ( listId, listType, trackId, trackIdInOriginDatabase, databaseUuid, trackNumber )                     SELECT NEW.playlistId, 3, NEW.trackId, NEW.trackIdInOriginDatabase, NEW.databaseUuid, NEW.trackNumber                    FROM List AS l WHERE l.id = NEW.playlistId AND l.type = 3 AND l.isFolder = 0 ; END;
CREATE TRIGGER trigger_delete_CrateTrackList INSTEAD OF DELETE ON CrateTrackList FOR EACH ROW BEGIN   DELETE FROM ListTrackList WHERE listType = 4 AND OLD.crateId = listId AND OLD.trackId = trackId; END;
CREATE TRIGGER trigger_insert_CrateTrackList INSTEAD OF INSERT ON CrateTrackList FOR EACH ROW BEGIN   INSERT INTO ListTrackList ( listId, listType, trackId, trackIdInOriginDatabase, databaseUuid, trackNumber )    VALUES ( NEW.crateId, 4, NEW.trackId, 0, 0, 0 ) ; END;
CREATE INDEX index_ListHierarchy_listId ON ListHierarchy ( listId );
CREATE INDEX index_ListHierarchy_listType ON ListHierarchy ( listType );
CREATE INDEX index_ListHierarchy_listIdChild ON ListHierarchy ( listIdChild );
CREATE INDEX index_ListHierarchy_listTypeChild ON ListHierarchy ( listTypeChild );
CREATE VIEW CrateHierarchy AS SELECT listId AS crateId, listIdChild AS crateIdChild FROM ListHierarchy WHERE listType = 4 AND listTypeChild = 4;
CREATE TRIGGER trigger_delete_CrateHierarchy INSTEAD OF DELETE ON CrateHierarchy FOR EACH ROW BEGIN   DELETE FROM ListHierarchy WHERE listId = OLD.crateId AND listType = 4 AND listIdChild = OLD.crateIdChild AND listTypeChild = 4 ;  END;
CREATE TRIGGER trigger_insert_CrateHierarchy INSTEAD OF INSERT ON CrateHierarchy FOR EACH ROW BEGIN   INSERT INTO ListHierarchy ( listId, listType, listIdChild, listTypeChild )    VALUES ( NEW.crateId, 4, NEW.crateIdChild, 4 ) ; END;
CREATE INDEX index_ListParentList_listOriginId ON ListParentList ( listOriginId );
CREATE INDEX index_ListParentList_listOriginType ON ListParentList ( listOriginType );
CREATE INDEX index_ListParentList_listParentId ON ListParentList ( listParentId );
CREATE INDEX index_ListParentList_listParentType ON ListParentList ( listParentType );
CREATE VIEW CrateParentList AS SELECT listOriginId AS crateOriginId, listParentId AS crateParentId FROM ListParentList WHERE listOriginType = 4 AND listParentType = 4;
CREATE TRIGGER trigger_delete_CrateParentList INSTEAD OF DELETE ON CrateParentList FOR EACH ROW BEGIN   DELETE FROM ListParentList WHERE OLD.crateOriginId = listOriginId AND listOriginType = 4 AND OLD.crateParentId = listParentId AND listParentType = 4; END;
CREATE TRIGGER trigger_insert_CrateParentList INSTEAD OF INSERT ON CrateParentList FOR EACH ROW BEGIN   INSERT INTO ListParentList ( listOriginId, listOriginType, listParentId, listParentType )    VALUES ( NEW.crateOriginId, 4, NEW.crateParentId, 4 ) ; END;
COMMIT;
