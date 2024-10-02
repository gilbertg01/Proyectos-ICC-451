package edu.pucmm.icc451;

import android.os.Bundle;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.RecyclerView;

import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.Utilidades.AndroidUtil;

public class ChatActivity extends AppCompatActivity {

    Usuario auxUser;
    EditText Input;
    ImageButton sendBtn;
    ImageButton backBtn;
    TextView user2;
    RecyclerView recyclerView;

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
        Input = findViewById(R.id.message_input);
        sendBtn = findViewById(R.id.message_send_btn);
        backBtn = findViewById(R.id.back_btn);
        user2 = findViewById(R.id.user2);
        recyclerView = findViewById(R.id.message_recycler_view);

        backBtn.setOnClickListener(v -> {
            finish();
        });
        user2.setText(auxUser.getUsername());
    }
}
