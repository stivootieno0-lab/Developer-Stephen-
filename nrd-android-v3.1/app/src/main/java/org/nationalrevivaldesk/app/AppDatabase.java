package org.nationalrevivaldesk.app;
import android.content.Context;import androidx.room.*;
@Database(entities={OfflineAction.class},version=1,exportSchema=false) public abstract class AppDatabase extends RoomDatabase { private static volatile AppDatabase instance; public abstract OfflineActionDao queue(); public static AppDatabase get(Context context){ if(instance==null)synchronized(AppDatabase.class){ if(instance==null)instance=Room.databaseBuilder(context.getApplicationContext(),AppDatabase.class,"nrd_offline.db").fallbackToDestructiveMigration().build(); } return instance; } }
