package com.ghosten.videoplayer

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class PlayerDatabaseHelper(context: Context) : SQLiteOpenHelper(context, "playerThumbnails", null, 2) {
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            "CREATE TABLE IF NOT EXISTS $TABLE_NAME\n" +
                    "(\n" +
                    "    $FIELD_NAME_ID            INTEGER PRIMARY KEY,\n" +
                    "    $FIELD_NAME_URL           TEXT NOT NULL,\n" +
                    "    $FIELD_NAME_POSITION      INTEGER NOT NULL,\n" +
                    "    $FIELD_NAME_RELATIVE_PATH TEXT NOT NULL\n" +
                    ")"
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
    }

    fun insert(url: String, timeUs: Long, filename: String) {
        writableDatabase.insert(TABLE_NAME, null, ContentValues().apply {
            put(FIELD_NAME_URL, url)
            put(FIELD_NAME_POSITION, timeUs)
            put(FIELD_NAME_RELATIVE_PATH, filename)
        })
    }

    fun delete(url: String, timeUs: Long) {
        writableDatabase.delete(
            TABLE_NAME,
            "$FIELD_NAME_URL  = ? AND $FIELD_NAME_POSITION  = ?",
            arrayOf(url, timeUs.toString())
        )
    }

    fun queryPath(url: String, timeUs: Long): String? {
        val cursor = readableDatabase.rawQuery(
            "SELECT relativePath FROM $TABLE_NAME WHERE $FIELD_NAME_URL  = ? AND $FIELD_NAME_POSITION  = ?",
            arrayOf(url, timeUs.toString())
        )
        var path: String? = null
        with(cursor) {
            while (moveToNext()) {
                path = getString(getColumnIndexOrThrow(FIELD_NAME_RELATIVE_PATH))
            }
        }
        cursor.close()
        return path
    }

    companion object {
        const val TABLE_NAME = "cacheObject"
        const val FIELD_NAME_ID = "id"
        const val FIELD_NAME_URL = "url"
        const val FIELD_NAME_POSITION = "position"
        const val FIELD_NAME_RELATIVE_PATH = "relativePath"
    }
}
