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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.google.firebase.Timestamp;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.Locale;

import edu.pucmm.icc451.Entidad.Chat;
import edu.pucmm.icc451.Entidad.MensajeChat;
import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.Utilidades.AndroidUtil;
import edu.pucmm.icc451.Utilidades.ChatRecyclerAdapter;
import edu.pucmm.icc451.Utilidades.FirebaseUtil;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.Query;
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
    ChatRecyclerAdapter adapter;

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

        sendBtn.setOnClickListener((v -> {
            String mensaje = Input.getText().toString().trim();
            if(mensaje.isEmpty()){
                return;
            }
            enviarMensaje(mensaje);
        }));
        getChat();
        chatRecyclerView();
    }

    private void chatRecyclerView() {
        Query query = FirebaseUtil.getMensajeReference(chatId)
                .orderByChild("temporal");

        FirebaseRecyclerOptions<MensajeChat> options = new FirebaseRecyclerOptions.Builder<MensajeChat>()
                .setQuery(query, MensajeChat.class)
                .build();

        adapter = new ChatRecyclerAdapter(options, getApplicationContext());

        LinearLayoutManager manager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(manager);
        recyclerView.setAdapter(adapter);
        adapter.startListening();

        adapter.registerAdapterDataObserver(new RecyclerView.AdapterDataObserver() {
            @Override
            public void onItemRangeInserted(int positionStart, int itemCount) {
                super.onItemRangeInserted(positionStart, itemCount);
                recyclerView.smoothScrollToPosition(0);
            }
        });
    }


    private void enviarMensaje(String mensaje) {
        chat.setUltimoMensaje(ServerValue.TIMESTAMP);
        chat.setUltimoEnvioId(FirebaseUtil.currentUserId());
        chat.setUltimoMensajeStr(mensaje);

        FirebaseUtil.getChatReference(chatId).setValue(chat)
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful()) {
                        Log.e("Chat", "Error al actualizar el chat: " + task.getException());
                    }
                });
        MensajeChat mensajeChat = new MensajeChat(mensaje, FirebaseUtil.currentUserId(), ServerValue.TIMESTAMP);

        FirebaseUtil.getMensajeReference(chatId).push().setValue(mensajeChat)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        Input.setText("");
                    } else {
                        Log.e("Mensaje", "Error al enviar el mensaje: " + task.getException());
                    }
                });
    }

    private void getChat() {
        FirebaseUtil.getChatReference(chatId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // El chat ya existe, lo obtenemos de la base de datos
                    chat = dataSnapshot.getValue(Chat.class);

                    // Verificamos si el valor de ultimoMensaje es un Long (timestamp)
                    assert chat != null;
                    if (chat.getUltimoMensaje() instanceof Long) {
                        long timestamp = (Long) chat.getUltimoMensaje();

                        // Convertir el timestamp a una fecha
                        Date date = new Date(timestamp);
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.getDefault());
                        String formattedDate = sdf.format(date);
                        Log.d("Chat", "Ultimo mensaje enviado el: " + formattedDate);
                    }
                } else {
                    // El chat no existe, lo creamos
                    chat = new Chat(chatId, Arrays.asList(FirebaseUtil.currentUserId(), auxUser.getId()), ServerValue.TIMESTAMP, "");
                    FirebaseUtil.getChatReference(chatId).setValue(chat).addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            Log.d("Chat", "Chat creado exitosamente.");
                        } else {
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
