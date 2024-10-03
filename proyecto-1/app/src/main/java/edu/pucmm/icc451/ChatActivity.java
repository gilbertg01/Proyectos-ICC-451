package edu.pucmm.icc451;

import android.os.Bundle;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.Timestamp;

import java.util.Arrays;

import edu.pucmm.icc451.Entidad.Chat;
import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.Utilidades.AndroidUtil;
import edu.pucmm.icc451.Utilidades.FirebaseUtil;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ServerValue;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import android.util.Log;


public class ChatActivity extends AppCompatActivity {

    Usuario auxUser;
    EditText Input;
    ImageButton sendBtn;
    ImageButton backBtn;
    TextView user2;
    RecyclerView recyclerView;
    String chatId;
    Chat chat;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_chat);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        auxUser = AndroidUtil.getUserModelFromIntent(getIntent());
        chatId = FirebaseUtil.getChatId(FirebaseUtil.currentUserId(), auxUser.getId());

        Input = findViewById(R.id.message_input);
        sendBtn = findViewById(R.id.message_send_btn);
        backBtn = findViewById(R.id.back_btn);
        user2 = findViewById(R.id.user2);
        recyclerView = findViewById(R.id.message_recycler_view);

        backBtn.setOnClickListener(v -> {
            finish();
        });
        user2.setText(auxUser.getUsername());
        getChat();
    }

    void getChat() {
        FirebaseUtil.getChatReference(chatId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // El chat ya existe, lo obtenemos de la base de datos
                    chat = dataSnapshot.getValue(Chat.class);
                }
                else {
                    // El chat no existe, lo creamos
                    chat = new Chat(chatId, Arrays.asList(FirebaseUtil.currentUserId(), auxUser.getId()), ServerValue.TIMESTAMP, "");
                    FirebaseUtil.getChatReference(chatId).setValue(chat).addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            Log.d("Chat", "Chat creado exitosamente.");
                        }
                        else {
                            Log.e("Chat", "Error al crear el chat.");
                        }
                    });
                }
            }
            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                Log.e("Chat", "Error al obtener el chat: " + databaseError.getMessage());
            }
        });
    }
}
