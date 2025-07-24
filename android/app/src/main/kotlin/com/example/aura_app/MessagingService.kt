package com.example.aura_app

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "MessagingService"
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Log.d(TAG, "From: ${remoteMessage.from}")

        // Verificar si el mensaje contiene una notificación
        remoteMessage.notification?.let {
            Log.d(TAG, "Message Notification Body: ${it.body}")
            // La notificación se mostrará automáticamente cuando la app esté en background
            // Si necesitas lógica personalizada, puedes agregarla aquí
        }

        // Verificar si el mensaje contiene datos
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "Message data payload: ${remoteMessage.data}")

            // Aquí puedes procesar los datos adicionales si es necesario
            handleDataPayload(remoteMessage.data)
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "Refreshed token: $token")

        // Enviar el token actualizado a Appwrite
        // Esto se manejará desde Flutter a través del channel method
        sendTokenToAppwrite(token)
    }

    private fun handleDataPayload(data: Map<String, String>) {
        val type = data["type"]
        when (type) {
            "conversation_invitation" -> {
                // Manejar invitación de conversación
                Log.d(TAG, "Invitación de conversación recibida")
            }
            "invitation_response" -> {
                // Manejar respuesta de invitación
                Log.d(TAG, "Respuesta de invitación recibida")
            }
            else -> {
                Log.d(TAG, "Tipo de notificación desconocido: $type")
            }
        }
    }

    private fun sendTokenToAppwrite(token: String) {
        // Este método será llamado desde Flutter a través de platform channels
        // Por ahora solo registramos el token
        Log.d(TAG, "Token que debe ser enviado a Appwrite: $token")
    }
}
