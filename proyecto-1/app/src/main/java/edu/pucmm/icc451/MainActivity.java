package edu.pucmm.icc451;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageButton;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.HashMap;
import java.util.Map;

import edu.pucmm.icc451.Utilidades.FirebaseUtil;

public class MainActivity extends AppCompatActivity {

    FirebaseAuth auth;
    ChatFragment chat;
    ImageButton searchButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        auth = FirebaseAuth.getInstance();
        //FirebaseUser user = auth.getCurrentUser();
        BottomNavigationView bottomNavigationView = findViewById(R.id.bottom_navigation);
        chat = new ChatFragment();
        searchButton = findViewById(R.id.main_search_btn);

        searchButton.setOnClickListener(v -> {
            startActivity(new Intent(MainActivity.this, SearchActivity.class));
        });


        bottomNavigationView.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.menu_logout) {
                FirebaseMessaging.getInstance().deleteToken().addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        auth.signOut();
                        Intent intent = new Intent(getApplicationContext(), Login.class);
                        startActivity(intent);
                        finish();
                    }
                });
                return true;
            }
            if (item.getItemId() == R.id.menu_chat) {
                getSupportFragmentManager().beginTransaction().replace(R.id.main_frame_layout, chat).commit();
                return true;
            }
            return false;
        });
        bottomNavigationView.setSelectedItemId(R.id.menu_chat);
        getFCMToken();
    }

    void getFCMToken(){
        FirebaseMessaging.getInstance().getToken().addOnCompleteListener(task -> {
            if(task.isSuccessful()){
                String token = task.getResult();
                Map<String, Object> updates = new HashMap<>();
                updates.put("fcmToken", token);
                // Actualiza el token en la base de datos
                FirebaseUtil.currentUserDetails().updateChildren(updates)
                        .addOnCompleteListener(updateTask -> {
                            if(updateTask.isSuccessful()){
                                Log.d("FCMToken", "Token actualizado correctamente");
                            } else {
                                Log.e("FCMToken", "Error al actualizar el token", updateTask.getException());
                            }
                        });
            } else {
                Log.e("FCMToken", "Error al obtener el token de FCM", task.getException());
            }
        });
    }
}
