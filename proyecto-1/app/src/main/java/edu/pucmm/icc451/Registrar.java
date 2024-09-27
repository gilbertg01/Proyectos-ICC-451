package edu.pucmm.icc451;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
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
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;

public class Registrar extends AppCompatActivity {

    ProgressBar progressBar;
    FirebaseAuth auth = FirebaseAuth.getInstance();
    FirebaseDatabase database;
    DatabaseReference reference;

    @Override
    public void onStart() {
        super.onStart();
        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser != null) {
            Intent intent = new Intent(getApplicationContext(), MainActivity.class);
            startActivity(intent);
            finish();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_registrar);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
        TextInputEditText editTextUser = findViewById(R.id.usuario);
        TextInputEditText editTextEmail = findViewById(R.id.email);
        TextInputEditText editTextPassword = findViewById(R.id.password);
        Button btnReg = findViewById(R.id.btn_registrar);
        progressBar = findViewById(R.id.progressBar);
        TextView loginNow = findViewById(R.id.LoginNow);
        loginNow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getApplicationContext(), Login.class);
                startActivity(intent);
                finish();
            }
        });

        FirebaseAuth.AuthStateListener authStateListener = firebaseAuth -> {
            FirebaseUser currentUser = firebaseAuth.getCurrentUser();
            if (currentUser != null) {
                Log.i("AuthStateListener", "User: " + currentUser.getEmail());
            }
        };
        auth.addAuthStateListener(authStateListener);

        btnReg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                progressBar.setVisibility(View.VISIBLE);
                String user =  String.valueOf(editTextUser.getText());
                String email =  String.valueOf(editTextEmail.getText());
                String password = String.valueOf(editTextPassword.getText());

                if (TextUtils.isEmpty(email)) {
                    Toast.makeText(Registrar.this, "Enter email", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (TextUtils.isEmpty(password)) {
                    Toast.makeText(Registrar.this, "Enter password", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (password.length() < 6) {
                    Toast.makeText(Registrar.this, "Password too short, enter minimum 6 characters", Toast.LENGTH_SHORT).show();
                    return;
                }
                createUser(auth, user, email, password);
            }
        });

    }

    private void createUser(FirebaseAuth auth, String usuario, String email, String password) {
        auth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull @NotNull Task<AuthResult> task) {
                        progressBar.setVisibility(View.GONE);
                        if (task.isSuccessful()) {
                            FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                            assert user != null;
                            user.sendEmailVerification();

                            String id = user.getUid();
                            database = FirebaseDatabase.getInstance();
                            reference = database.getReference("users").child(id);

                            Usuario usuario1 = new Usuario(id, usuario, email, "default");
                            reference.setValue(usuario1).addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if (task.isSuccessful()) {
                                        Log.i("Database", "User data saved successfully in the database");
                                        Toast.makeText(Registrar.this, "User registered and saved in database", Toast.LENGTH_SHORT).show();
                                    } else {
                                        Log.e("Database", "Failed to save user data in the database");
                                        Toast.makeText(Registrar.this, "Failed to save user data", Toast.LENGTH_SHORT).show();
                                    }
                                }
                            });
                            Log.i("AuthStateListener", "User: " + user.getEmail());
                            Toast.makeText(Registrar.this, "Registered: " + user.getEmail(), Toast.LENGTH_SHORT).show();
                        } else {
                            Log.e("AuthStateListener", "User registration failed");
                            Toast.makeText(Registrar.this, "User registration failed", Toast.LENGTH_SHORT).show();
                        }
                    }
                }).addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull @NotNull Exception e) {
                        Log.e("AuthStateListener", "Failed to create user", e);
                        Toast.makeText(Registrar.this, "Failed to create user: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
    }
}