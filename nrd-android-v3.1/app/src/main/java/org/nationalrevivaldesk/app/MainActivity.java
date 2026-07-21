package org.nationalrevivaldesk.app;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.InputType;
import android.view.ViewGroup;
import android.webkit.*;
import android.widget.*;
import com.google.android.material.button.MaterialButton;
import org.json.JSONObject;

public final class MainActivity extends Activity {
    private ApiClient api;
    private LinearLayout root;
    private String radioStream="https://s3.radio.co/s97f38db97/listen";
    private ValueCallback<Uri[]> fileCallback;
    private static final int FILE_PICKER=700;

    @Override public void onCreate(Bundle state){
        super.onCreate(state); api=new ApiClient(this); SyncWorker.schedule(this);
        if(Build.VERSION.SDK_INT>=33)requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS},5);
        if(api.token().isEmpty())showLogin();else showDashboard();
    }
    private int dp(int v){return Math.round(v*getResources().getDisplayMetrics().density);}
    private void page(){ScrollView sc=new ScrollView(this);root=new LinearLayout(this);root.setOrientation(LinearLayout.VERTICAL);root.setPadding(dp(22),dp(18),dp(22),dp(30));root.setBackgroundColor(Color.rgb(244,247,252));sc.addView(root);setContentView(sc);}
    private TextView heading(String t){TextView v=new TextView(this);v.setText(t);v.setTextSize(25);v.setTextColor(Color.rgb(5,47,131));v.setTypeface(null,1);v.setPadding(0,dp(10),0,dp(10));root.addView(v);return v;}
    private TextView paragraph(String t){TextView v=new TextView(this);v.setText(t);v.setTextSize(16);v.setTextColor(Color.rgb(51,65,85));v.setPadding(0,dp(4),0,dp(13));root.addView(v);return v;}
    private EditText input(String h){EditText e=new EditText(this);e.setHint(h);e.setBackgroundColor(Color.WHITE);e.setPadding(dp(14),dp(12),dp(14),dp(12));LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(0,dp(5),0,dp(8));root.addView(e,p);return e;}
    private MaterialButton button(String t){MaterialButton b=new MaterialButton(this);b.setText(t);b.setAllCaps(false);LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(0,dp(5),0,dp(5));root.addView(b,p);return b;}
    private void toast(String m){runOnUiThread(()->Toast.makeText(this,m,Toast.LENGTH_LONG).show());}
    private interface Task{void run()throws Exception;} private void async(Task t){new Thread(()->{try{t.run();}catch(Exception e){toast(e.getMessage());}}).start();}

    private void showLogin(){
        page(); ImageView logo=new ImageView(this);logo.setImageResource(R.drawable.nrd_logo);logo.setAdjustViewBounds(true);root.addView(logo,new LinearLayout.LayoutParams(-1,dp(175)));
        heading("National Revival Desk 3.3");paragraph("Secure reporting, weekly planning, offline synchronization and ministry radio for national, provincial, county and regional coordination.");
        EditText email=input("Official email address");email.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        EditText password=input("Password");password.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_PASSWORD);
        MaterialButton login=button("Sign in");
        button("Register as Coordinator").setOnClickListener(v->showWeb(getString(R.string.registration_url)));
        button("Open public website").setOnClickListener(v->showWeb(getString(R.string.backend_url)));
        login.setOnClickListener(v->{if(email.getText().toString().trim().isEmpty()||password.getText().toString().isEmpty()){toast("Enter your email and password.");return;}login.setEnabled(false);async(()->{try{JSONObject out=api.post("api/mobile_login.php",new JSONObject().put("email",email.getText().toString().trim()).put("password",password.getText().toString()).put("device_name",Build.MANUFACTURER+" "+Build.MODEL).put("app_version","3.3.0"));api.saveToken(out.getString("token"));runOnUiThread(this::showDashboard);}finally{runOnUiThread(()->login.setEnabled(true));}});});
    }
    private void showDashboard(){
        page();heading("Coordinator Dashboard");TextView summary=paragraph("Loading verified dashboard data…");
        async(()->{JSONObject out=api.get("api/mobile_dashboard.php");JSONObject radio=out.optJSONObject("radio");if(radio!=null&&!radio.optString("stream").isEmpty())radioStream=radio.optString("stream");JSONObject stats=out.optJSONObject("stats");runOnUiThread(()->summary.setText(stats==null?"Connected":"Reports: "+stats.optInt("reports")+"\nMedia: "+stats.optInt("media")+"\nNotifications: "+stats.optInt("notifications")+"\nMeetings: "+stats.optInt("meetings")));});
        button("Create multi-step report").setOnClickListener(v->showWeb(getString(R.string.backend_url)+"coordinator/submit_report.php"));
        button("Submit weekly plan").setOnClickListener(v->showWeb(getString(R.string.backend_url)+"coordinator/weekly_plan.php"));
        button("Offline workspace & sync").setOnClickListener(v->showWeb(getString(R.string.backend_url)+"offline.html"));
        button("My reports").setOnClickListener(v->showWeb(getString(R.string.backend_url)+"coordinator/reports.php"));
        button("Notifications").setOnClickListener(v->showWeb(getString(R.string.backend_url)+"coordinator/notifications.php"));
        button("Digital Coordinator ID").setOnClickListener(v->showWeb(getString(R.string.backend_url)+"coordinator/identity_card.php"));
        button("Play Jesus is LORD Radio").setOnClickListener(v->{Intent i=new Intent(this,RadioService.class);i.setAction(RadioService.ACTION_PLAY);i.putExtra(RadioService.EXTRA_STREAM,radioStream);if(Build.VERSION.SDK_INT>=26)startForegroundService(i);else startService(i);});
        button("Stop radio").setOnClickListener(v->{Intent i=new Intent(this,RadioService.class);i.setAction(RadioService.ACTION_STOP);startService(i);});
        button("Log out").setOnClickListener(v->{api.logout();CookieManager.getInstance().removeAllCookies(null);showLogin();});
    }
    private void showWeb(String url){
        WebView web=new WebView(this);WebSettings settings=web.getSettings();settings.setJavaScriptEnabled(true);settings.setDomStorageEnabled(true);settings.setDatabaseEnabled(true);settings.setCacheMode(WebSettings.LOAD_DEFAULT);settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);CookieManager.getInstance().setAcceptCookie(true);
        web.setWebViewClient(new WebViewClient(){@Override public boolean shouldOverrideUrlLoading(WebView view,WebResourceRequest request){String host=request.getUrl().getHost();return host==null||!(host.equals("nationalrevivaldesk.online")||host.endsWith(".nationalrevivaldesk.online"));}});
        web.setWebChromeClient(new WebChromeClient(){@Override public boolean onShowFileChooser(WebView view,ValueCallback<Uri[]> callback,FileChooserParams params){if(fileCallback!=null)fileCallback.onReceiveValue(null);fileCallback=callback;try{startActivityForResult(params.createIntent(),FILE_PICKER);return true;}catch(Exception e){fileCallback=null;return false;}}});
        web.loadUrl(url);setContentView(web);
    }
    @Override protected void onActivityResult(int requestCode,int resultCode,Intent data){super.onActivityResult(requestCode,resultCode,data);if(requestCode==FILE_PICKER&&fileCallback!=null){fileCallback.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(resultCode,data));fileCallback=null;}}
    @Override public void onBackPressed(){ViewGroup content=findViewById(android.R.id.content);if(content!=null&&content.getChildCount()>0&&content.getChildAt(0)instanceof WebView){WebView web=(WebView)content.getChildAt(0);if(web.canGoBack()){web.goBack();return;}showDashboard();return;}super.onBackPressed();}
}
