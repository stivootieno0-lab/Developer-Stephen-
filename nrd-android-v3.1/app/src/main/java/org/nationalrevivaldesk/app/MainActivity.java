package org.nationalrevivaldesk.app;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import org.json.JSONArray;
import org.json.JSONObject;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public final class MainActivity extends Activity {
    private ApiClient api;
    private LinearLayout root;
    private String radioStream = "https://s3.radio.co/s97f38db97/listen";
    private String siteBase;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        api = new ApiClient(this);
        siteBase = getString(R.string.backend_url).replaceAll("/+$", "");
        if (Build.VERSION.SDK_INT >= 33) requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, 5);
        if (api.token().isEmpty()) showLogin(); else showDashboard();
    }

    private void buildPage() {
        ScrollView scroll = new ScrollView(this);
        root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(24), dp(20), dp(24), dp(32));
        root.setBackgroundColor(Color.rgb(244, 247, 252));
        scroll.addView(root);
        setContentView(scroll);
    }

    private int dp(int value) { return Math.round(value * getResources().getDisplayMetrics().density); }
    private TextView heading(String text) { TextView v=new TextView(this);v.setText(text);v.setTextSize(25);v.setTextColor(Color.rgb(5,47,131));v.setTypeface(null,1);v.setPadding(0,dp(12),0,dp(12));root.addView(v);return v; }
    private TextView paragraph(String text) { TextView v=new TextView(this);v.setText(text);v.setTextSize(16);v.setTextColor(Color.rgb(15,23,42));v.setPadding(0,dp(6),0,dp(14));root.addView(v);return v; }
    private EditText input(String hint) { EditText f=new EditText(this);f.setHint(hint);f.setSingleLine(false);f.setBackgroundColor(Color.WHITE);f.setPadding(dp(14),dp(12),dp(14),dp(12));LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(0,dp(6),0,dp(8));root.addView(f,p);return f; }
    private Button button(String text) { Button b=new Button(this);b.setText(text);b.setTextSize(16);b.setAllCaps(false);LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(0,dp(5),0,dp(5));root.addView(b,p);return b; }
    private void toast(String message) { runOnUiThread(() -> Toast.makeText(this,message==null?"Operation failed":message,Toast.LENGTH_LONG).show()); }
    private interface Task { void run() throws Exception; }
    private void async(Task task) { new Thread(() -> { try { task.run(); } catch (Exception error) { toast(error.getMessage()); } }).start(); }
    private void openWeb(String path) { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(siteBase + "/" + path.replaceFirst("^/+", "")))); }

    private void showLogin() {
        buildPage();
        ImageView logo=new ImageView(this);logo.setImageResource(R.drawable.nrd_logo);logo.setAdjustViewBounds(true);logo.setPadding(dp(30),dp(10),dp(30),dp(10));root.addView(logo,new LinearLayout.LayoutParams(-1,dp(190)));
        TextView name=heading("National Revival Desk");name.setGravity(Gravity.CENTER_HORIZONTAL);
        TextView intro=paragraph("Secure mobile access for coordinators, administrators and ministry leadership.");intro.setGravity(Gravity.CENTER_HORIZONTAL);
        EditText email=input("Official email address");email.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        EditText password=input("Password");password.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_PASSWORD);
        Button login=button("Sign in");
        Button register=button("Register as Coordinator");
        register.setOnClickListener(view -> openWeb("signup/"));
        button("Open public website").setOnClickListener(view -> openWeb(""));
        paragraph("Registration opens the professional multi-step form for personal information, jurisdiction, church leadership, security review and administrator approval.");
        login.setOnClickListener(view -> {
            String emailText=email.getText().toString().trim(),passwordText=password.getText().toString();
            if(emailText.isEmpty()||passwordText.isEmpty()){toast("Enter your email and password.");return;}
            login.setEnabled(false);
            async(() -> { try { JSONObject result=api.post("api/mobile_login.php",new JSONObject().put("email",emailText).put("password",passwordText).put("device_name",Build.MANUFACTURER+" "+Build.MODEL).put("app_version","3.3.0"));api.saveToken(result.getString("token"));runOnUiThread(this::showDashboard);} finally {runOnUiThread(() -> login.setEnabled(true));} });
        });
    }

    private void showDashboard() {
        buildPage();heading("Dashboard");TextView summary=paragraph("Loading your dashboard…");
        async(() -> { JSONObject output=api.get("api/mobile_dashboard.php");JSONObject radio=output.optJSONObject("radio");if(radio!=null&&!radio.optString("stream").isEmpty())radioStream=radio.optString("stream");JSONObject stats=output.optJSONObject("stats");String text=stats==null?"Dashboard connected.":"Reports: "+stats.optInt("reports")+"\nMedia: "+stats.optInt("media")+"\nNotifications: "+stats.optInt("notifications")+"\nMeetings: "+stats.optInt("meetings");runOnUiThread(() -> summary.setText(text)); });
        button("Submit revival report").setOnClickListener(view -> showSubmitReport());
        button("View reports").setOnClickListener(view -> showList("Reports","api/mobile_reports.php","reports"));
        button("Notifications").setOnClickListener(view -> showList("Notifications","api/mobile_notifications.php","notifications"));
        button("Meetings").setOnClickListener(view -> showList("Meetings","api/mobile_meetings.php","meetings"));
        button("Support chat").setOnClickListener(view -> showSupport());
        button("Open Coordinator Registration").setOnClickListener(view -> openWeb("signup/"));
        button("Open professional report portal").setOnClickListener(view -> openWeb("public_reports.php"));
        button("Play Jesus is LORD Radio").setOnClickListener(view -> { Intent i=new Intent(this,RadioService.class);i.setAction(RadioService.ACTION_PLAY);i.putExtra(RadioService.EXTRA_STREAM,radioStream);if(Build.VERSION.SDK_INT>=26)startForegroundService(i);else startService(i); });
        button("Stop radio").setOnClickListener(view -> { Intent i=new Intent(this,RadioService.class);i.setAction(RadioService.ACTION_STOP);startService(i); });
        button("Log out").setOnClickListener(view -> {api.logout();showLogin();});
    }

    private void showSubmitReport() {
        buildPage();heading("Submit Revival Report");paragraph("Your approved registration jurisdiction is validated by the server.");
        EditText date=input("Event date YYYY-MM-DD");date.setText(new SimpleDateFormat("yyyy-MM-dd",Locale.US).format(new Date()));
        EditText reportTitle=input("Report title"),altar=input("Altar"),category=input("Category"),description=input("Detailed report");description.setMinLines(5);
        Button submit=button("Submit report");
        submit.setOnClickListener(view -> { if(reportTitle.getText().toString().trim().isEmpty()||description.getText().toString().trim().isEmpty()){toast("Enter a report title and description.");return;}submit.setEnabled(false);async(() -> {try{JSONObject body=new JSONObject().put("revival_date",date.getText().toString().trim()).put("title",reportTitle.getText().toString().trim()).put("altar",altar.getText().toString().trim()).put("category",category.getText().toString().trim()).put("description",description.getText().toString().trim());api.post("api/mobile_submit_report.php",body);toast("Report submitted successfully.");runOnUiThread(this::showDashboard);}finally{runOnUiThread(() -> submit.setEnabled(true));}});});
        button("Back to dashboard").setOnClickListener(view -> showDashboard());
    }

    private void showList(String title,String endpoint,String arrayName) {
        buildPage();heading(title);TextView contents=paragraph("Loading…");async(() -> {JSONObject output=api.get(endpoint);JSONArray records=output.optJSONArray(arrayName);StringBuilder text=new StringBuilder();if(records!=null)for(int i=0;i<records.length();i++){JSONObject record=records.optJSONObject(i);if(record==null)continue;text.append("• ").append(record.optString("title",record.optString("subject","Item"))).append("\n").append(record.optString("description",record.optString("body",record.optString("message","")))).append("\n\n");}runOnUiThread(() -> contents.setText(text.length()==0?"No records found.":text.toString()));});button("Back to dashboard").setOnClickListener(view -> showDashboard());
    }

    private void showSupport() {
        buildPage();heading("Support Chat");EditText subject=input("Subject"),message=input("Describe the assistance required");message.setMinLines(5);Button send=button("Send support request");send.setOnClickListener(view -> async(() -> {api.post("api/mobile_support.php",new JSONObject().put("subject",subject.getText().toString().trim()).put("message",message.getText().toString().trim()));toast("Support request sent.");runOnUiThread(this::showDashboard);}));button("Back to dashboard").setOnClickListener(view -> showDashboard());
    }
}
