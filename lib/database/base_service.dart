import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// The BaseModel class is an abstract class which we can enhance at a later point
/// to add functionality for our data models. Currently it does not provide any
/// value other than as a placeholder
abstract class BaseModel {
  BaseModel();
  // factory BaseModel.fromJson() => null;
  // Map<String, dynamic> toJson() => null;
}

class EmptyModel implements BaseModel {}

/// The BaseTableHelper class is an abstract class to define a few of the
/// required functions for all table helper classes
abstract class BaseTableHelper {
  /// NOTE: currently the cacheDuration feature is not used
  /// the [cacheDuration] parameter was originally intended to enable
  /// developers the ability to set an expiration time limit on the data
  /// cached in SQFLite. At the expiration of the cache duration, the
  /// entire table would re-load from the server. This is not currently implemented

  // cause a force refresh of the cache every 3 years. This
  // effectively prevents cache refreshes (Needs implementation)
  BaseTableHelper({
    this.cacheDuration = 365 * 3 * 86400000,
    this.humanReadableTableName = '<no human readable table name>',
    this.remoteDbId = '<no remote db ID>',
    this.pageSize = 250,
    this.tableFlag = 0,
  });

  num cacheDuration;

  /// [tableFlag] is a bit field that identifies this table within the
  /// calling application.
  int tableFlag;

  /// [pageSize] is an integer that determines how many records will be in o
  /// page of data feteched from the database at one time. If the number
  /// of records equals the page size. The system knows to issue another
  /// request.
  int pageSize;

  /// [humanReadableTableName] is a string that holds the name of the table
  /// in human readable form. This is mainly used during app initializaiton
  /// when we are displaying the progress of loading the app to the end user.
  String humanReadableTableName;

  /// [remoteDbId] is a string that contains the name of the primary key field
  /// in the remote database. It should also normally serve as the primary key for the
  /// data in SQFLite
  String remoteDbId;

  /// [secondaryKey] is a string that contains the name of an additional key field
  /// in the remote database in cases where we have a compound primary key.
  /// If empty, only the remoteDbId is used as a key, if populated, both the
  /// remoteDbId and the secondaryKey will be used to uniquely identify records
  String? secondaryKey;

  /// [tertiaryKey] is a string that contains the name of a third additional key field
  /// in the remote database in cases where we have a compound primary key.
  /// If empty, only the remoteDbId and possibly the secondary keys are used, if populated,
  /// all three keys will be used. NOTE: if the secondary key is empty, but the tertiary key
  /// is populated, it will be ignored.
  String? tertiaryKey;

  /// [getTableName] is a function that returns the SQFLite table name for a given
  /// data entity based on the current app domain. App domains allow us to have more
  /// than one copy of a table in the mobile device at any one time. For example,
  /// An app can have a "user" mode and an "admin" mode. In "user" mode a given table
  /// might only contain records relevant to that one user, in "admin" an identical copy of
  /// the table might exist that contains information for all users. Each of these two tables
  /// will have a different name depending on the specific appDomain.
  String getTableName(dynamic appDomainType) => '<no table name>';

  /// Upon initialization we create SQFLite tables for each data entity, here's the method signature for
  /// that function
  Future<void> createTable(Database db, int version, dynamic appDomainType) async {
    return;
  }

  /// After the tables have been created and loaded, we then apply any required indexes
  Future<void> createIndexes(Database db, int version, dynamic appDomainType) async {
    return;
  }

  /// [normalizeMap] is used to take json content from the wire and normalize it against the data model
  /// resident in the current mobile device. This allows developers to add fields to the wire
  /// without breaking older versions of the app. Typically the [normalizeMap] function is called just once
  /// each time data is returned. If the number of fields on the wire equals the number of fields in the
  /// specified entity, it does not have to be called a second time. If the number of fields is different,
  /// [normalizeMap] will return a map of JSON objects that has been stripped of any fields that
  /// are not present in the on-device database.
  Map<String, dynamic> normalizeMap(Map<String, dynamic> inputMap) => <String, dynamic>{};

  /// [fromMap] is pretty self explanitory, it converts a map of JSON objects to the corresponding data object
  BaseModel fromMap(Map<String, dynamic> map) {
    return EmptyModel();
  }
}

/// [BaseFields] are fields that are required for each data entity
mixin BaseFields {
  /// [colId] is the field name for the internal primary key of the data in SQFLite.
  /// It is an integer primary key that is not typically used by the app
  final String colId = 'id';

  /// [removed] is an integer flag that indicates whether or not a database record is
  /// active. A value of '0' indicates that the record is active, a value of '1' indicates
  /// that a record has been deleted. Typically, once a record on the mobile device has been
  /// flagged with a [removed] value of '1' it can be deleted from the on-device database.
  /// We still need to do some work on how records get deleted from the mobile device when they
  /// have been flagged as removed.
  final String colRemoved = 'removed';

  /// The [updatedAt] field is essential to our replication scheme. When a sync is done with the
  /// server, the mobile device sends the last [updatedAt] timestamp value to the server. The server then
  /// sends only those records that have an [updatedAt] timestamp value that is greater than the one
  /// on the device. Doing this, we can cache data on the device and only push changes from the
  /// server when necessary. The [updatedAt] timestamp is GMT and can only be set by the central database.
  /// By having only a single source of time for the [updatedAt] value (i.e. the database server), we ensure
  /// that proper sync is maintained across all devices. [updatedAt] is a string value with the GMT time
  /// that the record was last updated.
  final String colUpdatedAt = 'updatedAt';

  /// [updatedAtValue] is a numeric representation of the [updatedAt] timestamp string
  final String colUpdatedAtValue = 'updatedAtValue';
}

class BaseService {
  /// For a given table and appDomain, [selectAllFromLocalDb] returns a list that contains all objects in the table
  Future<List<BaseModel>> selectAllFromLocalDb(Database db, BaseTableHelper tableHelper, dynamic appDomainType) async {
    final List<Map<String, dynamic>> result = await db.query(tableHelper.getTableName(appDomainType));

    final List<BaseModel> records = <BaseModel>[];

    if (result.isNotEmpty) {
      for (int i = 0; i < result.length; i++) {
        if (result[i]['removed'] == 0) {
          final BaseModel record = tableHelper.fromMap(result[i]);
          records.add(record);
        }
      }
    }
    return records;
  }

  /// [getLastUpdatedTime] returns a numeric value that represents the latest time a record contained in
  /// the table was updated. This is used for database replication.
  Future<num> getLastUpdatedTime(Database db, BaseTableHelper tableHelper, String tableName, String colUpdatedAtValue) async {
    final List<Map<String, dynamic>> table = await db.rawQuery('SELECT MAX($colUpdatedAtValue) AS maxDate FROM $tableName');
    final num timeValue = table.first['maxDate'] as num;
    return timeValue;
  }

  /// [clearTable] deletes all records from a SQFLite table
  Future<void> clearTable(Database db, BaseTableHelper tableHelper, String tableName) async {
    final String query = 'DELETE FROM $tableName';
    await db.rawDelete(query).then((void dummy) {
      // NOTE: When we re-implmeent cache clearing, uncomment the code below
      //setIntPrefStrKey(LAST_CACHE_CLEAR_KEY + tableHelper.getTableName(tableType), DateTime.now().millisecondsSinceEpoch);
    });
  }

  /// The [updateSqlTablesFromJsonWithAdHocData] function is the publicly accessible function for updating data in
  /// the SQFLite database. This is the only mechanism used to get data from the wire into the
  /// internal SQFLite DB. We typically call this function with the raw results received from
  /// the wire. These results can contain data from many tables, so we need to be able to
  /// process them all at once. The results can also contain 'adHocData' which is not intended
  /// to be inserted into any table. In this case, we need to return the adHocData to the calling
  /// function.

  Future<List<dynamic>> updateSqlTablesFromJsonWithAdHocData(
    String jsonResults,
    List<BaseTableHelper> tables,
    Database db,
    dynamic appDomainType, {
    Function? informUser,
    bool suppressDeletes = false,
    String batchText = '',
  }) async {
    // Some API calls return adHocData that is not intended to be inserted into the
    // internal SQFLite DB. This data can be used for a variety of reasons within the app.
    // Get ready to return some ad hoc data.
    List<dynamic> adHocData = <dynamic>[]; // prepare to return an empty list instead of null

    // Sometimes, the results on the wire consist of an array of result sets from many different
    // SQL tables on the remote DB. We want to
    // process them one at a time, so if that's the case, remove the outer brackets
    // from the result string
    if (jsonResults.startsWith('[[')) {
      jsonResults = jsonResults.substring(1, jsonResults.length - 1);
    }

    // using REGEX, pull out each of the result sets from the data
    final RegExp r = RegExp(r'\[(\{(.*?)\})\]', multiLine: true);
    final Iterable<Match> matches = r.allMatches(jsonResults);
    for (int i = 0; i < matches.length; i++) {
      // grab a single result set
      final String? ms = matches.elementAt(i).group(0);

      bool isProcessed = false;

      if (ms != null) {
        // are we processing adHocData?
        if (ms.startsWith(r'[{"adHocDataId"')) {
          isProcessed = true;
          final List<dynamic> adHocItems = jsonDecode(ms) as List<dynamic>;
          if (adHocItems.isNotEmpty) {
            adHocData = adHocItems;
          }
        } else {
          // if we are not processing adHocData,
          // look through the tables that we are allowed to insert into and see if
          // we can find which one has the same remoteDbId as is present in the received data
          for (final BaseTableHelper helper in tables) {
            if (ms.startsWith('[{"${helper.remoteDbId}"')) {
              isProcessed = true;
              // we found a table that matches the received data, so go ahead
              // and do a bulk insert into the SQFLite DB.
              await bulkUpdateDatabase(helper, helper.getTableName(appDomainType), '[$ms]', db, informUser: informUser, suppressDeletes: suppressDeletes, batchText: batchText);
            }
          }
        }

        if (!isProcessed) {
          // in the SQL stored procedures that process the data, sometimes we run across an error
          // (e.g. such as an invalid access token). This data will contain an arbitrary 'errorId'
          // field that serves as a flag that an error has occurred. When this happens, put the
          // error information into the adHocData variable and return that to the caller.
          if (ms.startsWith(r'[{"errorId"')) {
            final List<dynamic> errorItems = jsonDecode(ms) as List<dynamic>;
            if (errorItems.isNotEmpty) {
              adHocData = errorItems;
            }
            print('server messages received');
          } else {
            // There is a chance that the server returned data that this version
            // of the software is not expecting, such as in cases when new features
            // have been added to new releases and this is an older release
            // in these cases, just ignore the extra data.
            // It is also possible that we have received data that the app developer
            // has chosen to ignore by not passing in the appropriate table into the
            // list of tables when this function was called.

            // Just to be safe, do a debug print anyway
            // and remind the developer that the first field in the result set must be
            // the primary key of the remote DB so we can match the internal table with
            // the received data.
            print('The following data was not inserted into the device DB');
            print('Please ensure that you are passing in all tables that you want processed by this function in the "tables" parameter');
            print('Also, it is required that the primary key for the table to be the first field in the JSON data. Please check the JSON data format.');
            print(ms);
          }
        }
      }
    }

    return adHocData;
  }

  Future<List<Map<String, dynamic>>> getSqlFieldsById(BaseTableHelper tableHelper, Database db, String id, dynamic appDomainType, {String? secondaryId, String? tertiaryId}) async {
    final String tableName = tableHelper.getTableName(appDomainType);

    String query;

    if ((secondaryId == null) || (secondaryId.isEmpty)) {
      query = '''
          SELECT *
          FROM $tableName
          WHERE ${tableHelper.remoteDbId} = "$id"
          ''';
    } else if ((tertiaryId == null) || (tertiaryId.isEmpty)) {
      query = '''
          SELECT *
          FROM $tableName
          WHERE ${tableHelper.remoteDbId} = "$id" AND ${tableHelper.secondaryKey} = "$secondaryId" 
          ''';
    } else {
      query = '''
          SELECT *
          FROM $tableName
          WHERE ${tableHelper.remoteDbId} = "$id" AND ${tableHelper.secondaryKey} = "$secondaryId" AND ${tableHelper.tertiaryKey} = "$tertiaryId" 
          ''';
    }

    final List<Map<String, dynamic>> results = await db.rawQuery(query);
    return results;
  }

  Future<int> updateSqlTablesFromJsonWithPaging(
    String jsonResults,
    List<BaseTableHelper> tables,
    Database db,
    dynamic appDomainType, {
    Function? informUser,
    bool suppressDeletes = false,
    String batchText = '',
  }) async {
    // Some API calls return adHocData that is not intended to be inserted into the
    // internal SQFLite DB. This data can be used for a variety of reasons within the app.
    // Get ready to return some ad hoc data.
    List<dynamic> adHocData = <dynamic>[]; // prepare to return an empty list instead of null

    int tablesToPage = 0;

    // Sometimes, the results on the wire consist of an array of result sets from many different
    // SQL tables on the remote DB. We want to
    // process them one at a time, so if that's the case, remove the outer brackets
    // from the result string
    if (jsonResults.startsWith('[[')) {
      jsonResults = jsonResults.substring(1, jsonResults.length - 1);
    }

    // using REGEX, pull out each of the result sets from the data
    final RegExp r = RegExp(r'\[(\{(.*?)\})\]', multiLine: true);
    final Iterable<Match> matches = r.allMatches(jsonResults);
    for (int i = 0; i < matches.length; i++) {
      // grab a single result set
      final String? ms = matches.elementAt(i).group(0);

      bool isProcessed = false;

      if (ms != null) {
        // are we processing adHocData?
        if (ms.startsWith(r'[{"adHocDataId"')) {
          isProcessed = true;
          final List<dynamic> adHocItems = jsonDecode(ms) as List<dynamic>;
          if (adHocItems.isNotEmpty) {
            adHocData = adHocItems;
          }
        } else {
          // if we are not processing adHocData,
          // look through the tables that we are allowed to insert into and see if
          // we can find which one has the same remoteDbId as is present in the received data
          for (final BaseTableHelper helper in tables) {
            if (ms.startsWith('[{"${helper.remoteDbId}"')) {
              isProcessed = true;
              // we found a table that matches the received data, so go ahead
              // and do a bulk insert into the SQFLite DB.
              final bool additionalPageSyncRequired =
                  await bulkUpdateDatabase(helper, helper.getTableName(appDomainType), '[$ms]', db, informUser: informUser, suppressDeletes: suppressDeletes, batchText: batchText);

              if (additionalPageSyncRequired) {
                tablesToPage |= helper.tableFlag;
              }
            }
          }
        }

        if (!isProcessed) {
          // in the SQL stored procedures that process the data, sometimes we run across an error
          // (e.g. such as an invalid access token). This data will contain an arbitrary 'errorId'
          // field that serves as a flag that an error has occurred. When this happens, put the
          // error information into the adHocData variable and return that to the caller.
          if (ms.startsWith(r'[{"errorId"')) {
            final List<dynamic> errorItems = jsonDecode(ms) as List<dynamic>;
            if (errorItems.isNotEmpty) {
              adHocData = errorItems;
            }
            print('server messages received');
          } else {
            // There is a chance that the server returned data that this version
            // of the software is not expecting, such as in cases when new features
            // have been added to new releases and this is an older release
            // in these cases, just ignore the extra data.
            // It is also possible that we have received data that the app developer
            // has chosen to ignore by not passing in the appropriate table into the
            // list of tables when this function was called.

            // Just to be safe, do a debug print anyway
            // and remind the developer that the first field in the result set must be
            // the primary key of the remote DB so we can match the internal table with
            // the received data.
            print('The following data was not inserted into the device DB');
            print('Please ensure that you are passing in all tables that you want processed by this function in the "tables" parameter');
            print('Also, it is required that the primary key for the table to be the first field in the JSON data. Please check the JSON data format.');
            print(ms);
          }
        }
      }
    }

    return tablesToPage;
  }

  /// [_bulkUpdateDatabase] is one of the most important functions in the replication system.
  /// For any given table [_bulkUpdateDatabase] takes raw json results in a string, checks to see that
  /// the structure of that data matches the internal db using [normalizeMap] and then does a bulk update
  /// of the SQFlite table.
  /// ToDo (DevTeam): ultimately we need to find a way when a record has been deleted on the mobile device to make sure it does
  /// not keep getting sent over the wire. This can be challenging because one record on the central server may exist in many
  /// mobile devices. For now, we try to avoid deleting records if possible because this issue has not been addressed.
  Future<bool> bulkUpdateDatabase(BaseTableHelper tableHelper, String tableName, String rawResults, Database db, {Function? informUser, bool suppressDeletes = false, String batchText = ''}) async {
    int updateCounter = 0;
    int insertCounter = 0;
    int deletedCounter = 0;

    bool? doNormalizeMap;

    bool additionalPageAvailable = false;

    // results will come in as an array of json result sets, typically there will be only
    // one result set that contains an array of json objects, but in exceptional cases
    // there can be more than one result set.
    final List<dynamic> jsonResultSets = json.decode(rawResults) as List<dynamic>;
    print('$tableName result sets received from cloud = ${jsonResultSets.length}');

    // keep track of the percentage of results added to the DB so we can give the user
    // a status indication that the database is being populated. This is typically
    // only used when the database is first loaded.
    int lastPercentage = 0;

    // SQFLite is much more efficient when you batch database calls, so start a new batch
    final Batch batch = db.batch();

    // loop through the resul sets
    for (int i = 0; i < jsonResultSets.length; i++) {
      final List<dynamic> jsonResults = jsonResultSets[i] as List<dynamic>;
      print('$tableName results received from cloud = ${jsonResults.length}');

      additionalPageAvailable = jsonResults.length == tableHelper.pageSize;

      // then loop through the records in each result set
      for (int j = 0; j < jsonResults.length; j++) {
        Map<String, dynamic> fieldsOnTheWire = jsonResults[j] as Map<String, dynamic>;

        // the first time through the loop, check to see if the data on the wire matches the
        // data in the internal database. If it does not, we want to print out the name
        // of the fields that are either missing from the wire or missing from the internal database
        // for debugging purposes
        if (doNormalizeMap == null) {
          // using the data from the wire, get a map of json data that matches the fields
          // in the internal database.
          final Map<String, dynamic> internalDbFields = tableHelper.normalizeMap(fieldsOnTheWire);

          // set the doNormalizeMap variable accordingly
          doNormalizeMap = internalDbFields.length != fieldsOnTheWire.length;
          if (doNormalizeMap) {
            // if the fields don't match, we need to see where the differences are and do a debug print
            print('Normalize map called for $tableName, # of fields on the wire = ${fieldsOnTheWire.length}, # of fields in internal DB = ${internalDbFields.length}');

            // loop through the map of data from the wire and see if any of them
            // were not present in the internal database (this indicates a field has been added to the server
            // and has not yet been added to the mobile app).
            for (int k = 0; k < fieldsOnTheWire.length; k++) {
              final String key = fieldsOnTheWire.keys.elementAt(k);
              if (!internalDbFields.containsKey(key)) {
                print('$key field is on the wire but not in the internal database');
              }
            }

            // now loop through the data in the database and see if there are any field in SQFLite that
            // were not on the wire. (This is a much less common scenario than the one above. Once a field is
            // on the wire, we tend to leave it there.)
            for (int k = 0; k < internalDbFields.length; k++) {
              final String key = internalDbFields.keys.elementAt(k);
              if (!fieldsOnTheWire.containsKey(key)) {
                print('$key field is in the internal database but not on the wire');
              }
            }
          }
        }

        // how far along are we in processing our result set?
        final int percentage = (100 * (j / jsonResults.length)).round();

        // if the value has changed and a function pointer has been
        // passed in, notify the user of our progress
        if ((percentage != lastPercentage) && (informUser != null)) {
          lastPercentage = percentage;
          if (batchText.isNotEmpty) {
            informUser('Loading ${tableHelper.humanReadableTableName}\r\n$batchText\r\n$percentage% complete');
          } else {
            informUser('Loading ${tableHelper.humanReadableTableName}\r\n$percentage% complete');
          }
        }

        // Now that the housekeeping is done, let's normalize the data from the wire
        // to match the fields in the database. Note, we only need to do this
        // if the check we performed earlier indicates that the number of fields
        // on the wire is different than the number in the database.
        // important: make sure to normalize the map before adding the updatedAtValue, otherwise
        // the updatedAtValue will get removed from the data set!
        if (doNormalizeMap) {
          fieldsOnTheWire = tableHelper.normalizeMap(fieldsOnTheWire);
        }

        // since we are doing a bulk insert / update of the database, we need to append the 'updatedAtValue'
        fieldsOnTheWire.addAll(<String, dynamic>{
          'updatedAtValue': DateTime.parse(fieldsOnTheWire['updatedAt'].toString().padRight(28, '0')).microsecondsSinceEpoch,
        });

        String query;
        if ((tableHelper.secondaryKey == null) || (tableHelper.secondaryKey!.isEmpty)) {
          query = 'SELECT id FROM $tableName WHERE ${tableHelper.remoteDbId} = "${fieldsOnTheWire[tableHelper.remoteDbId]}"';
        } else if ((tableHelper.tertiaryKey == null) || (tableHelper.tertiaryKey!.isEmpty)) {
          query =
              'SELECT id FROM $tableName WHERE ${tableHelper.remoteDbId} = "${fieldsOnTheWire[tableHelper.remoteDbId]}" AND ${tableHelper.secondaryKey} = "${fieldsOnTheWire[tableHelper.secondaryKey]}"';
        } else {
          query =
              'SELECT id FROM $tableName WHERE ${tableHelper.remoteDbId} = "${fieldsOnTheWire[tableHelper.remoteDbId]}" AND ${tableHelper.secondaryKey} = "${fieldsOnTheWire[tableHelper.secondaryKey]}" AND ${tableHelper.tertiaryKey} = "${fieldsOnTheWire[tableHelper.tertiaryKey]}"';
        }

        // does the record already exist in the database? Check using the remoteDbId.
        final List<Map<String, dynamic>> localDbRecord = await db.rawQuery(query);

        // has the record been marked as deleted?
        if (suppressDeletes || (jsonResults[j]['removed'] ?? 0) == 0) {
          // nope, the remote record has not been marked as deleted, so process either an insert or update

          // (just a little error check here to make sure that the remoteDb table contains a removed record)
          if (jsonResults[j]['removed'] == null) {
            print('$tableName should implement a removed field');
          }

          // did our query of the localDb return a record based on the remoteDbId?
          if (localDbRecord.isEmpty) {
            // no, the record does not yet exist, so add a new one
            batch.insert(tableName, fieldsOnTheWire);
            insertCounter++;
          } else {
            // get the internal SQFLite primary key of the reocrd we want to update
            final String rowId = localDbRecord.first['id'].toString();
            // ...and update it!
            batch.update(tableName, fieldsOnTheWire, where: 'id = $rowId');
            updateCounter++;
          }
        } else {
          // the 'removed' flag was non-zero, so we need to delete the record
          // from the internal DB if it exists.
          if (localDbRecord.isNotEmpty) {
            // grab the primary key as we did above
            final String rowId = localDbRecord.first['id'].toString();
            if (rowId.isNotEmpty) {
              // and delete if required
              batch.delete(tableName, where: 'id = $rowId');
              deletedCounter++;
            }
          }
        }

        // // every 250 records do a commit. I'm not sure if this will improve performance, but it's worth a try
        // if ((j % 250) == 0) {
        //   await batch.commit(noResult: true);
        //   batch = db.batch();
        // }
      }
    }

    // at the end of all of this, commit the results.
    await batch.commit(noResult: true);

    // and debug print the results
    print('$insertCounter $tableName records inserted, $updateCounter $tableName records updated, $deletedCounter $tableName records deleted');
    return additionalPageAvailable;
  }
}
