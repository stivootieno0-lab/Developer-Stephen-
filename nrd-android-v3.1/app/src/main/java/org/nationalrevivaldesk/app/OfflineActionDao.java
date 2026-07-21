package org.nationalrevivaldesk.app;
import androidx.room.*;import java.util.List;
@Dao public interface OfflineActionDao { @Query("SELECT * FROM offline_actions WHERE status IN ('pending','failed') ORDER BY id LIMIT 25") List<OfflineAction> pending(); @Insert long insert(OfflineAction action); @Query("UPDATE offline_actions SET status=:status, attempts=attempts+1 WHERE id=:id") void update(long id,String status); @Query("DELETE FROM offline_actions WHERE id=:id") void delete(long id); }
