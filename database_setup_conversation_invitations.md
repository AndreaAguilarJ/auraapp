# Configuración de la Colección: conversation_invitations

## Atributos a crear en Appwrite Console:

### 1. fromUserId
- **Type**: String
- **Size**: 255
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)

### 2. fromUserName  
- **Type**: String
- **Size**: 255
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)

### 3. toUserId
- **Type**: String
- **Size**: 255
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)

### 4. toUserName
- **Type**: String
- **Size**: 255
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)

### 5. topic
- **Type**: String
- **Size**: 2000
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)
- **Nota**: Almacenará el tema como JSON string

### 6. status
- **Type**: String
- **Size**: 50
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: "pending"

### 7. message (opcional)
- **Type**: String
- **Size**: 1000
- **Required**: ❌ No
- **Array**: ❌ No
- **Default**: (vacío)

### 8. createdAt
- **Type**: DateTime
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)

### 9. respondedAt (opcional)
- **Type**: DateTime
- **Required**: ❌ No  
- **Array**: ❌ No
- **Default**: (vacío)

### 10. expiresAt
- **Type**: DateTime
- **Required**: ✅ Sí
- **Array**: ❌ No
- **Default**: (vacío)

## Configurar Permisos:

### Permisos de Lectura (Read):
- `users:*` (Todos los usuarios autenticados)

### Permisos de Creación (Create):
- `users:*` (Todos los usuarios autenticados)

### Permisos de Actualización (Update):
- `users:*` (Todos los usuarios autenticados)

### Permisos de Eliminación (Delete):
- `users:*` (Todos los usuarios autenticados)

## Índices a crear:

1. **Para consultas por destinatario**:
   - Key: `toUserId_status`
   - Type: `key`
   - Attributes: `toUserId`, `status`

2. **Para consultas por remitente**:
   - Key: `fromUserId_createdAt`
   - Type: `key`
   - Attributes: `fromUserId`, `$createdAt`

3. **Para consultas por fecha de expiración**:
   - Key: `status_expiresAt`
   - Type: `key`
   - Attributes: `status`, `expiresAt`
