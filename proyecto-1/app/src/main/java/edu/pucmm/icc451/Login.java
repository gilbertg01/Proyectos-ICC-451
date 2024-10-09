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
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import org.jetbrains.annotations.NotNull;

import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.Utilidades.AndroidUtil;
import edu.pucmm.icc451.Utilidades.FirebaseUtil;

public class Login extends AppCompatActivity {

    ProgressBar progressBar;
    FirebaseAuth auth;

    @Override
    public void onStart() {
        super.onStart();
        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser != null) {
            // Verifica si el intent viene de una notificacion
            if (getIntent().getExtras() != null) {
                String userId = getIntent().getExtras().getString("Id");
                if (userId != null) {
                    // Obtener el usuario de Firebase Realtime Database
                    FirebaseUtil.allUserCollectionReference().child(userId)
                            .addListenerForSingleValueEvent(new ValueEventListener() {
                                @Override
                                public void onDataChange(@NonNull DataSnapshot snapshot) {
                                    if (snapshot.exists()) {
                                        Usuario user = snapshot.getValue(Usuario.class);
                                        // Redirige primero al MainActivity para mantener el flujo de la app
                                        Intent mainIntent = new Intent(Login.this, MainActivity.class);
                                        mainIntent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                                        startActivity(mainIntent);

                                        // Luego redirige al ChatActivity con los datos del usuario
                                        Intent intent = new Intent(Login.this, ChatActivity.class);
                                        assert user != null;
                                        AndroidUtil.passUserModelAsIntent(intent, user);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                        startActivity(intent);
                                        finish(); // Cierra el LoginActivity
                                    }
                                }
                                @Override
                                public void onCancelled(@NonNull DatabaseError error) {
                                    Log.e("FirebaseError", "Error al obtener el usuario", error.toException());
                                }
                            });
                }
            }
            else {
                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                startActivity(intent);
                finish();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        TextInputEditText editTextEmail = findViewById(R.id.email);
        TextInputEditText editTextPassword = findViewById(R.id.password);
        Button btnLog = findViewById(R.id.btn_login);
        progressBar = findViewById(R.id.progressBar);
        TextView registerNow = findViewById(R.id.RegisterNow);
        auth = FirebaseAuth.getInstance();
        registerNow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getApplicationContext(), Registrar.class);
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

        btnLog.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                progressBar.setVisibility(View.VISIBLE);
                String email =  String.valueOf(editTextEmail.getText());
                String password = String.valueOf(editTextPassword.getText());

                if (TextUtils.isEmpty(email)) {
                    Toast.makeText(Login.this, "Enter email", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (TextUtils.isEmpty(password)) {
                    Toast.makeText(Login.this, "Enter password", Toast.LENGTH_SHORT).show();
                    return;
                }
                login(auth, email, password);
            }
        });
    }

    private void login(FirebaseAuth auth, String email, String password) {
        auth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull @NotNull Task<AuthResult> task) {
                        progressBar.setVisibility(View.GONE);
                        if (task.isSuccessful()) {
                            FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                            assert user != null;
                            if(!user.isEmailVerified()){
                                Log.i("EmailVerification", "User not verified: " + user.getEmail());
                                Toast.makeText(Login.this, "User not verified: " + user.getEmail(), Toast.LENGTH_SHORT).show();
                            }
                            else {
                                Log.i("AuthStateListener", "User: " + user.getEmail());
                                Toast.makeText(Login.this, "Logged in: " + user.getEmail(), Toast.LENGTH_SHORT).show();
                                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                                startActivity(intent);
                                finish();
                            }
                        }
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull @NotNull Exception e) {
                        Log.e("AuthStateListener", "Failed to create user", e);
                        Toast.makeText(Login.this, "Failed to create user: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
    }
}