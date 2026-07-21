package org.nationalrevivaldesk.app;
import androidx.room.Entity;import androidx.room.PrimaryKey;
@Entity(tableName="offline_actions") public class OfflineAction { @PrimaryKey(autoGenerate=true) public long id; public String clientUuid; public String endpoint; public String payloadJson; public String status="pending"; public int attempts=0; public long createdAt=System.currentTimeMillis(); }
