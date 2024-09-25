package edu.pucmm.icc451;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

import org.jetbrains.annotations.NotNull;

public class MainActivity extends AppCompatActivity {

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

        Button btnLogin = findViewById(R.id.btnLogin);
        Button btnCreate = findViewById(R.id.btnCreate);

        FirebaseAuth.AuthStateListener authStateListener = firebaseAuth -> {
            FirebaseUser currentUser = firebaseAuth.getCurrentUser();
            if (currentUser != null) {
                Log.i("AuthStateListener", "User: " + currentUser.getEmail());
            }
        };

        FirebaseAuth auth = FirebaseAuth.getInstance();
        auth.addAuthStateListener(authStateListener);

        btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                login(auth);
            }
        });

        btnCreate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                createUser(auth);
            }
        });

    }

    private void login(FirebaseAuth auth) {
        auth.signInWithEmailAndPassword("jccb0001@ce.pucmm.edu.do", "p@ssw@rd")
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull @NotNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                            assert user != null;
                            saveUserPreferences(user.getEmail());
                            if(!user.isEmailVerified()){
                                Log.i("EmailVerification", "User not verified: " + user.getEmail());
                                Toast.makeText(MainActivity.this, "User not verified: " + user.getEmail(), Toast.LENGTH_SHORT).show();
                            }
                            else {
                                Log.i("AuthStateListener", "User: " + user.getEmail());
                                Toast.makeText(MainActivity.this, "Logged in: " + user.getEmail(), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull @NotNull Exception e) {
                        Log.e("AuthStateListener", "Failed to create user", e);
                        Toast.makeText(MainActivity.this, "Failed to create user: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void createUser(FirebaseAuth auth){
        auth.createUserWithEmailAndPassword("jccb0001@ce.pucmm.edu.do", "p@ssw@rd")
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull @NotNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                            assert user != null;
                            user.sendEmailVerification();
                            Log.i("AuthStateListener", "User: " + user.getEmail());
                            Toast.makeText(MainActivity.this, "Logged in: " + user.getEmail(), Toast.LENGTH_SHORT).show();
                        }
                    }
                }).addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull @NotNull Exception e) {
                        Log.e("AuthStateListener", "Failed to create user", e);
                        Toast.makeText(MainActivity.this, "Failed to create user:" + e, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void saveUserPreferences(String email) {
        SharedPreferences shared = getSharedPreferences("UserPref", MODE_PRIVATE);
        SharedPreferences.Editor editor = shared.edit();

        editor.putString("email", email);
        editor.apply();
    }

//    private String getUserPreferences() {
//        SharedPreferences shared = getSharedPreferences("UserPref", MODE_PRIVATE);
//        return shared.getString("email", "");
//    }
}