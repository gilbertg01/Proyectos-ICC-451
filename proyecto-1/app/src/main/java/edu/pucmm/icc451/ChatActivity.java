package edu.pucmm.icc451;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.work.Data;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.Timestamp;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import edu.pucmm.icc451.Entidad.Chat;
import edu.pucmm.icc451.Entidad.MensajeChat;
import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.Utilidades.AndroidUtil;
import edu.pucmm.icc451.Utilidades.ChatRecyclerAdapter;
import edu.pucmm.icc451.Utilidades.FirebaseUtil;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.Query;
import com.google.firebase.database.ServerValue;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import android.util.Log;
import org.json.JSONObject;

import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.OkHttpClient;
import okhttp3.Call;
import org.json.JSONException;

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
    private static final int PICK_IMAGE_REQUEST = 1;
    ImageButton imageSendBtn;
    private ActivityResultLauncher<Intent> imagePickerLauncher;
    FirebaseAuth auth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_chat);
        Objects.requireNonNull(getSupportActionBar()).hide();
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, 70, systemBars.right, systemBars.bottom);
            return insets;
        });
        auth = FirebaseAuth.getInstance();
        auxUser = AndroidUtil.getUserModelFromIntent(getIntent());
        chatId = FirebaseUtil.getChatId(FirebaseUtil.currentUserId(), auxUser.getId());

        Input = findViewById(R.id.message_input);
        sendBtn = findViewById(R.id.message_send_btn);
        backBtn = findViewById(R.id.back_btn);
        user2 = findViewById(R.id.user2);
        recyclerView = findViewById(R.id.message_recycler_view);

        imagePickerLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == RESULT_OK && result.getData() != null && result.getData().getData() != null) {
                        Uri imageUri = result.getData().getData();
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), imageUri);
                            String encodedImage = encodeImageToBase64(bitmap);
                            enviarMensajeImagen(encodedImage);
                        } catch (IOException e) {
                            Log.e("ChatActivity", "Error al convertir la imagen: " + e.getMessage());
                        }
                    }
                }
        );

        imageSendBtn = findViewById(R.id.image_send_btn);
        imageSendBtn.setOnClickListener(v -> openImageSelector());

        backBtn.setOnClickListener(v -> {
            finish();
        });
        user2.setText(auxUser.getUsername());

        TextView userStatus = findViewById(R.id.user_status);
        DatabaseReference userRef = FirebaseUtil.getUserReference(auxUser.getId());

        userRef.child("enLinea").addValueEventListener(new ValueEventListener() {
            @SuppressLint("SetTextI18n")
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                Boolean enLinea = snapshot.getValue(Boolean.class);
                if (enLinea != null && enLinea) {
                    userStatus.setText("En linea");
                } else {
                    userStatus.setText("Desconectado");
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.e("ChatActivity", "Error al obtener el estado de conexión", error.toException());
            }
        });

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

    private void openImageSelector() {
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        imagePickerLauncher.launch(Intent.createChooser(intent, "Selecciona una imagen"));
    }

    // Método para convertir la imagen a Base64
    private String encodeImageToBase64(Bitmap bitmap) {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream);
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        return Base64.encodeToString(byteArray, Base64.DEFAULT);
    }

    private void enviarMensajeImagen(String encodedImage) {
        chat.setUltimoMensaje(ServerValue.TIMESTAMP);
        chat.setUltimoEnvioId(FirebaseUtil.currentUserId());
        chat.setUltimoMensajeStr("[Imagen]");

        FirebaseUtil.getChatReference(chatId).setValue(chat)
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful()) {
                        Log.e("Chat", "Error al actualizar el chat: " + task.getException());
                    }
                });

        MensajeChat mensajeChat = new MensajeChat(encodedImage, FirebaseUtil.currentUserId(), ServerValue.TIMESTAMP);
        mensajeChat.setTipoMensaje("imagen"); // Marcar el mensaje como imagen

        FirebaseUtil.getMensajeReference(chatId).push().setValue(mensajeChat)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        Log.d("Mensaje", "Imagen enviada correctamente.");
                        sendNotification("Imagen");
                    } else {
                        Log.e("Mensaje", "Error al enviar la imagen: " + task.getException());
                    }
                });
    }


    private void chatRecyclerView() {
        Query query = FirebaseUtil.getMensajeReference(chatId)
                .orderByChild("temporal");

        FirebaseRecyclerOptions<MensajeChat> options = new FirebaseRecyclerOptions.Builder<MensajeChat>()
                .setQuery(query, MensajeChat.class)
                .build();

        adapter = new ChatRecyclerAdapter(options, getApplicationContext());

        LinearLayoutManager manager = new LinearLayoutManager(this);
        manager.setStackFromEnd(true); // Coloca los mensajes más recientes al final
        recyclerView.setLayoutManager(manager);
        recyclerView.setAdapter(adapter);
        adapter.startListening();

        adapter.registerAdapterDataObserver(new RecyclerView.AdapterDataObserver() {
            @Override
            public void onItemRangeInserted(int positionStart, int itemCount) {
                super.onItemRangeInserted(positionStart, itemCount);
                int lastVisiblePosition = manager.findLastCompletelyVisibleItemPosition();
                if (lastVisiblePosition == -1 ||
                        (positionStart >= (adapter.getItemCount() - 1) && lastVisiblePosition == (positionStart - 1))) {
                    recyclerView.smoothScrollToPosition(positionStart);
                }
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
                        sendNotification(mensaje);
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

    private void sendNotification(String message) {
        FirebaseUtil.currentUserDetails().get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                Usuario currentUser = task.getResult().getValue(Usuario.class);  // Correct Firebase Realtime Database conversion
                if (currentUser != null) {
                    // Use ExecutorService to run network operations off the main thread
                    ExecutorService executorService = Executors.newSingleThreadExecutor();
                    executorService.execute(() -> {
                        try {
                            // Move network operations here
                            String token = getAccessToken(this);  // Generate the OAuth 2.0 token on a background thread
                            JSONObject payload = createNotificationPayload(currentUser, message, auxUser.getFcmToken());
                            callApi(payload, token);  // Send the notification in the background
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    });
                }
            }
        });
    }


    private JSONObject createNotificationPayload(Usuario currentUser, String message, String recipientFcmToken) throws JSONException {
        JSONObject notificationPayload = new JSONObject();

        // Notification content
        JSONObject notificationObj = new JSONObject();
        notificationObj.put("title", currentUser.getUsername());  // Title of the notification
        notificationObj.put("body", message);  // Body of the notification

        // Additional data (optional)
        JSONObject dataObj = new JSONObject();
        dataObj.put("Id", currentUser.getId());  // Example: sending the userId in the data

        // FCM message structure
        JSONObject messageObj = new JSONObject();
        messageObj.put("token", recipientFcmToken);  // Recipient's FCM token
        messageObj.put("notification", notificationObj);  // Attach the notification object
        messageObj.put("data", dataObj);  // Attach the data object

        // Final payload
        notificationPayload.put("message", messageObj);
        return notificationPayload;
    }


    private void callApi(JSONObject jsonObject, String accessToken) {
        MediaType JSON = MediaType.get("application/json; charset=utf-8");
        OkHttpClient client = new OkHttpClient();

        // FCM v1 API endpoint
        String url = "https://fcm.googleapis.com/v1/projects/chat-app-225be/messages:send";

        // Create the request body
        RequestBody body = RequestBody.create(jsonObject.toString(), JSON);

        // Add the OAuth 2.0 access token in the Authorization header
        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .header("Authorization", "Bearer " + accessToken)  // Use the token here
                .header("Content-Type", "application/json")
                .build();

        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NonNull okhttp3.Call call, @NonNull IOException e) {
                // Print the error stack trace for network issues
                System.err.println("Network request failed: " + e.getMessage());
                e.printStackTrace();
            }

            @Override
            public void onResponse(@NonNull okhttp3.Call call, @NonNull okhttp3.Response response) throws IOException {
                if (response.isSuccessful()) {  // Ensure the response was successful
                    System.out.println("Notification sent successfully");
                } else {
                    // Print the error response for debugging
                    String errorBody = response.body() != null ? response.body().string() : "No error body";
                    System.err.println("Failed to send notification");
                    System.err.println("Response Code: " + response.code());
                    System.err.println("Error Body: " + errorBody);
                }
            }
        });
    }

    public String getAccessToken(Context context) throws IOException {
        // Path to your service account key file inside the assets folder
        String pathToServiceAccount = "chat-app-225be-firebase-adminsdk-7rxpy-ac9efc1d4a.json";

        // Use the context to open the file from the assets directory
        InputStream serviceAccount = context.getAssets().open(pathToServiceAccount);

        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(serviceAccount)
                .createScoped(Collections.singleton("https://www.googleapis.com/auth/firebase.messaging"));

        googleCredentials.refreshIfExpired(); // Make sure the token is fresh
        return googleCredentials.getAccessToken().getTokenValue();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (auth.getCurrentUser() != null) {
            FirebaseUtil.currentUserDetails().child("enLinea").setValue(true);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (auth.getCurrentUser() != null) {
            FirebaseUtil.currentUserDetails().child("enLinea").setValue(false);
        }
    }
}
