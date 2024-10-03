package edu.pucmm.icc451.Entidad;

import java.util.Map;

public class MensajeChat {
    private String mensaje;
    private String emisorId;
    private Map<String, String> temporal;

    public MensajeChat() {
    }

    public MensajeChat(String mensaje, String emisorId, Map<String, String> temporal) {
        this.mensaje = mensaje;
        this.emisorId = emisorId;
        this.temporal = temporal;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getEmisorId() {
        return emisorId;
    }

    public void setEmisorId(String emisorId) {
        this.emisorId = emisorId;
    }

    public Map<String, String> getTemporal() {
        return temporal;
    }

    public void setTemporal(Map<String, String> temporal) {
        this.temporal = temporal;
    }
}