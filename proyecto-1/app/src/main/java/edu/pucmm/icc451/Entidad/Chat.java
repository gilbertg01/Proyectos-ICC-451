package edu.pucmm.icc451.Entidad;

import java.util.List;
import java.util.Map;

public class Chat {
    private String id;
    private List<String> userIds;
    private Object ultimoMensaje;
    private String ultimoEnvioId;

    public Chat() {
    }

    public Chat(String id, List<String> userIds, Object ultimoMensaje, String ultimoEnvioId) {
        this.id = id;
        this.userIds = userIds;
        this.ultimoMensaje = ultimoMensaje;
        this.ultimoEnvioId = ultimoEnvioId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<String> getUserIds() {
        return userIds;
    }

    public void setUserIds(List<String> userIds) {
        this.userIds = userIds;
    }

    public Object getUltimoMensaje() {
        return ultimoMensaje;
    }

    public void setUltimoMensaje(Object ultimoMensaje) {
        this.ultimoMensaje = ultimoMensaje;
    }

    public String getUltimoEnvioId() {
        return ultimoEnvioId;
    }

    public void setUltimoEnvioId(String ultimoEnvioId) {
        this.ultimoEnvioId = ultimoEnvioId;
    }
}
