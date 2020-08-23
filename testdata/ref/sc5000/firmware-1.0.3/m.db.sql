PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE Track ( [id] INTEGER, [playOrder] INTEGER , [length] INTEGER , [lengthCalculated] INTEGER , [bpm] INTEGER , [year] INTEGER , [path] TEXT , [filename] TEXT , [bitrate] INTEGER , [bpmAnalyzed] REAL , [trackType] INTEGER , [isExternalTrack] NUMERIC , [uuidOfExternalDatabase] TEXT , [idTrackInExternalDatabase] INTEGER , [idAlbumArt] INTEGER  REFERENCES AlbumArt ( id )  ON DELETE RESTRICT, [pdbImportKey] INTEGER , PRIMARY KEY ( [id] ) );
CREATE TABLE Information ( [id] INTEGER, [uuid] TEXT , [schemaVersionMajor] INTEGER , [schemaVersionMinor] INTEGER , [schemaVersionPatch] INTEGER , [currentPlayedIndiciator] INTEGER , [lastRekordBoxLibraryImportReadCounter] INTEGER , PRIMARY KEY ( [id] ) );
INSERT INTO Information VALUES(1,'9948f20d-ef0c-4703-8278-2e78002e0806',1,7,1,3665948354972031658,0);
CREATE TABLE MetaData ( [id] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE, [type] INTEGER, [text] TEXT , PRIMARY KEY ( [id], [type] ) );
CREATE TABLE MetaDataInteger ( [id] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE, [type] INTEGER, [value] INTEGER , PRIMARY KEY ( [id], [type] ) );
CREATE TABLE Playlist ( [id] INTEGER, [title] TEXT , PRIMARY KEY ( [id] ) );
CREATE TABLE PlaylistTrackList ( [playlistId] INTEGER  REFERENCES Playlist ( id )  ON DELETE CASCADE, [trackId] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE, [trackIdInOriginDatabase] INTEGER , [databaseUuid] TEXT , [trackNumber] INTEGER );
CREATE TABLE PreparelistTrackList ( [playlistId] INTEGER  REFERENCES Preparelist ( id )  ON DELETE CASCADE, [trackId] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE, [trackIdInOriginDatabase] INTEGER , [databaseUuid] TEXT , [trackNumber] INTEGER );
CREATE TABLE Preparelist ( [id] INTEGER, [title] TEXT , PRIMARY KEY ( [id] ) );
INSERT INTO Preparelist VALUES(1,'Prepare');
CREATE TABLE HistorylistTrackList ( [historylistId] INTEGER  REFERENCES Historylist ( id )  ON DELETE CASCADE, [trackId] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE, [trackIdInOriginDatabase] INTEGER , [databaseUuid] TEXT , [date] INTEGER );
CREATE TABLE Historylist ( [id] INTEGER, [title] TEXT , PRIMARY KEY ( [id] ) );
INSERT INTO Historylist VALUES(1,'History 1');
CREATE TABLE Crate ( [id] INTEGER, [title] TEXT , [path] TEXT , PRIMARY KEY ( [id] ) );
CREATE TABLE CrateParentList ( [crateOriginId] INTEGER  REFERENCES Crate ( id )  ON DELETE CASCADE, [crateParentId] INTEGER  REFERENCES Crate ( id )  ON DELETE CASCADE);
CREATE TABLE CrateTrackList ( [crateId] INTEGER  REFERENCES Crate ( id )  ON DELETE CASCADE, [trackId] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE);
CREATE TABLE CrateHierarchy ( [crateId] INTEGER  REFERENCES Crate ( id )  ON DELETE CASCADE, [crateIdChild] INTEGER  REFERENCES Crate ( id )  ON DELETE CASCADE);
CREATE TABLE AlbumArt ( [id] INTEGER, [hash] TEXT , [albumArt] BLOB , PRIMARY KEY ( [id] ) );
INSERT INTO AlbumArt VALUES(1,'',NULL);
CREATE TABLE CopiedTrack ( [trackId] INTEGER  REFERENCES Track ( id )  ON DELETE CASCADE, [uuidOfSourceDatabase] TEXT , [idOfTrackInSourceDatabase] INTEGER , PRIMARY KEY ( [trackId] ) );
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
CREATE INDEX index_Playlist_id ON Playlist ( id );
CREATE INDEX index_PlaylistTrackList_playlistId ON PlaylistTrackList ( playlistId );
CREATE INDEX index_PlaylistTrackList_trackId ON PlaylistTrackList ( trackId );
CREATE INDEX index_PreparelistTrackList_playlistId ON PreparelistTrackList ( playlistId );
CREATE INDEX index_PreparelistTrackList_trackId ON PreparelistTrackList ( trackId );
CREATE INDEX index_Preparelist_id ON Preparelist ( id );
CREATE INDEX index_HistorylistTrackList_historylistId ON HistorylistTrackList ( historylistId );
CREATE INDEX index_HistorylistTrackList_trackId ON HistorylistTrackList ( trackId );
CREATE INDEX index_HistorylistTrackList_date ON HistorylistTrackList ( date );
CREATE INDEX index_Historylist_id ON Historylist ( id );
CREATE INDEX index_Crate_id ON Crate ( id );
CREATE INDEX index_Crate_title ON Crate ( title );
CREATE INDEX index_Crate_path ON Crate ( path );
CREATE INDEX index_CrateParentList_crateOriginId ON CrateParentList ( crateOriginId );
CREATE INDEX index_CrateParentList_crateParentId ON CrateParentList ( crateParentId );
CREATE INDEX index_CrateTrackList_crateId ON CrateTrackList ( crateId );
CREATE INDEX index_CrateTrackList_trackId ON CrateTrackList ( trackId );
CREATE INDEX index_CrateHierarchy_crateId ON CrateHierarchy ( crateId );
CREATE INDEX index_CrateHierarchy_crateIdChild ON CrateHierarchy ( crateIdChild );
CREATE INDEX index_AlbumArt_id ON AlbumArt ( id );
CREATE INDEX index_AlbumArt_hash ON AlbumArt ( hash );
CREATE INDEX index_CopiedTrack_trackId ON CopiedTrack ( trackId );
COMMIT;
