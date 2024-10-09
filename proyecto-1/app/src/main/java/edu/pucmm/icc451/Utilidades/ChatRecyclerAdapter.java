package edu.pucmm.icc451.Utilidades;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import edu.pucmm.icc451.Entidad.MensajeChat;
import edu.pucmm.icc451.R;

public class ChatRecyclerAdapter extends FirebaseRecyclerAdapter<MensajeChat, ChatRecyclerAdapter.ChatModelViewHolder> {

    Context context;

    public ChatRecyclerAdapter(@NonNull FirebaseRecyclerOptions<MensajeChat> options, Context context) {
        super(options);
        this.context = context;
    }

    @Override
    protected void onBindViewHolder(@NonNull ChatModelViewHolder holder, int position, @NonNull MensajeChat model) {
        Log.i("ChatAdapter", "Mensaje recibido");

        // Verificamos si el mensaje es de tipo imagen
        if ("imagen".equals(model.getTipoMensaje())) {
            // Comprobar si el mensaje es del usuario actual
            if (model.getEmisorId().equals(FirebaseUtil.currentUserId())) {
                holder.leftChatLayout.setVisibility(View.GONE);
                holder.rightChatLayout.setVisibility(View.VISIBLE);
                holder.rightChatTextview.setVisibility(View.GONE); // Ocultar el TextView para mensajes de texto

                // Mostrar la imagen en el lado derecho
                byte[] decodedString = Base64.decode(model.getMensaje(), Base64.DEFAULT);
                Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
                holder.rightChatImage.setVisibility(View.VISIBLE);
                holder.rightChatImage.setImageBitmap(decodedByte);

                // Configurar la hora del mensaje para el lado derecho
                if (model.getTemporal() instanceof Long) {
                    String formattedDate = FirebaseUtil.timestampToString(model.getTemporal());
                    holder.rightChatTime.setText(formattedDate);
                }
            } else {
                holder.rightChatLayout.setVisibility(View.GONE);
                holder.leftChatLayout.setVisibility(View.VISIBLE);
                holder.leftChatTextview.setVisibility(View.GONE); // Ocultar el TextView para mensajes de texto

                // Mostrar la imagen en el lado izquierdo
                byte[] decodedString = Base64.decode(model.getMensaje(), Base64.DEFAULT);
                Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
                holder.leftChatImage.setVisibility(View.VISIBLE);
                holder.leftChatImage.setImageBitmap(decodedByte);

                // Configurar la hora del mensaje para el lado izquierdo
                if (model.getTemporal() instanceof Long) {
                    String formattedDate = FirebaseUtil.timestampToString(model.getTemporal());
                    holder.leftChatTime.setText(formattedDate);
                }
            }
        } else {
            // Lógica existente para mensajes de texto
            if (model.getEmisorId().equals(FirebaseUtil.currentUserId())) {
                holder.leftChatLayout.setVisibility(View.GONE);
                holder.rightChatLayout.setVisibility(View.VISIBLE);
                holder.rightChatTextview.setVisibility(View.VISIBLE); // Mostrar el TextView para mensajes de texto
                holder.rightChatImage.setVisibility(View.GONE); // Ocultar la vista de imagen

                holder.rightChatTextview.setText(model.getMensaje());

                // Configurar la hora del mensaje para el lado derecho
                if (model.getTemporal() instanceof Long) {
                    String formattedDate = FirebaseUtil.timestampToString(model.getTemporal());
                    holder.rightChatTime.setText(formattedDate);
                }
            } else {
                holder.rightChatLayout.setVisibility(View.GONE);
                holder.leftChatLayout.setVisibility(View.VISIBLE);
                holder.leftChatTextview.setVisibility(View.VISIBLE); // Mostrar el TextView para mensajes de texto
                holder.leftChatImage.setVisibility(View.GONE); // Ocultar la vista de imagen

                holder.leftChatTextview.setText(model.getMensaje());

                // Configurar la hora del mensaje para el lado izquierdo
                if (model.getTemporal() instanceof Long) {
                    String formattedDate = FirebaseUtil.timestampToString(model.getTemporal());
                    holder.leftChatTime.setText(formattedDate);
                }
            }
        }
    }

    @NonNull
    @Override
    public ChatModelViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.message_recycle_row, parent, false);
        return new ChatModelViewHolder(view);
    }

    class ChatModelViewHolder extends RecyclerView.ViewHolder {
        LinearLayout leftChatLayout, rightChatLayout;
        TextView leftChatTextview, rightChatTextview;
        TextView leftChatTime, rightChatTime;
        ImageView leftChatImage, rightChatImage;

        public ChatModelViewHolder(@NonNull View itemView) {
            super(itemView);
            leftChatLayout = itemView.findViewById(R.id.left_chat_layout);
            rightChatLayout = itemView.findViewById(R.id.right_chat_layout);
            leftChatTextview = itemView.findViewById(R.id.left_chat_textview);
            rightChatTextview = itemView.findViewById(R.id.right_chat_textview);
            leftChatTime = itemView.findViewById(R.id.left_chat_time);
            rightChatTime = itemView.findViewById(R.id.right_chat_time);
            leftChatImage = itemView.findViewById(R.id.left_chat_image);
            rightChatImage = itemView.findViewById(R.id.right_chat_image);
        }
    }

}
