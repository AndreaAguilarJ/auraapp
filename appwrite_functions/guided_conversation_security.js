// Función de seguridad para conversaciones guiadas
// Ejecutar en Appwrite Functions

export default async function (req, res) {
  const { userId, operation, documentData } = req.body;

  // Solo permitir operaciones a usuarios que son parte de la conversación
  if (operation === 'read' || operation === 'update') {
    const { initiatorUserId, partnerUserId } = documentData;

    if (userId !== initiatorUserId && userId !== partnerUserId) {
      return res.json({
        allowed: false,
        reason: 'Usuario no autorizado para esta conversación'
      });
    }
  }

  // Solo permitir crear conversaciones donde el usuario es el initiator
  if (operation === 'create') {
    if (userId !== documentData.initiatorUserId) {
      return res.json({
        allowed: false,
        reason: 'Solo puedes crear conversaciones donde eres el iniciador'
      });
    }
  }

  return res.json({ allowed: true });
}
