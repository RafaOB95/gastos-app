# Gastos Pareja: guía de instalación

App de gastos para los dos, instalada en sus iPhone sin pasar por la App Store. Se hace una sola vez desde una computadora y toma unos 20 minutos.

Necesitas:
- Esta carpeta, que es la app (es la que se sube a GitHub).
- El archivo `2_mis_datos_PRIVADO.sql`, que va aparte. **Ese no se sube a GitHub**, porque trae sus movimientos.

## 1. Crear la base de datos (Supabase)

1. Entra a supabase.com y crea una cuenta gratis.
2. Crea un proyecto nuevo con **New project**:
   - Nombre: `gastos-pareja`.
   - Inventa una contraseña de base de datos y guárdala.
   - Elige la región más cercana.
3. Espera a que termine de crearse (1 a 2 minutos).
4. Ve a **SQL Editor** y toca **New query**.
5. Pega todo el contenido de `supabase/1_esquema.sql` y toca **Run**. Debe decir "Success".
6. Ve a **Authentication › Sign In / Providers › Email**.
7. Apaga **Confirm email** y guarda. Así no tienen que confirmar por correo al crear su cuenta.
8. Ve a **Project Settings › API**.
9. Copia el **Project URL** y la clave **anon public**.

## 2. Poner tus datos de Supabase en la app

> En este paquete `config.js` ya trae tu Project URL y tu publishable key. Puedes saltarte este paso.

1. Abre `config.js` con cualquier editor de texto.
2. Reemplaza `PEGA_AQUI_TU_PROJECT_URL` por tu Project URL.
3. Reemplaza `PEGA_AQUI_TU_ANON_PUBLIC_KEY` por tu clave anon public.
4. Guarda el archivo.

La clave anon está hecha para ir dentro de la app. Lo que protege sus datos es la base: solo los miembros de su hogar pueden leerlos.

## 3. Publicar la app (GitHub Pages)

1. Entra a github.com y crea una cuenta gratis.
2. Crea un repositorio con **New repository**:
   - Nombre: `gastos-pareja`.
   - Debe ser **Public**, porque es requisito de GitHub Pages en el plan gratis. Solo el código queda público, no sus datos.
3. En el repositorio vacío, toca **uploading an existing file**.
4. Arrastra **todo el contenido** de esta carpeta: `index.html`, `config.js`, `sw.js`, `manifest.webmanifest` y las carpetas `icons`, `vendor` y `supabase`.
5. Toca **Commit changes**.
6. Ve a **Settings › Pages**. En **Branch** elige `main` y `/ (root)`, y toca **Save**.
7. Espera 1 o 2 minutos. Tu app queda en `https://TU-USUARIO.github.io/gastos-pareja/`.

## 4. Rafa: crear cuenta y hogar

1. Abre la dirección de la app en **Safari** en tu iPhone.
2. Toca **Crear cuenta** y pon tu correo y una contraseña.
3. Escribe el nombre del hogar (por ejemplo, "Rafa y Rebe") y toca **Crear nuestro hogar**.
4. La app dirá que el hogar está listo y te mostrará un código de 6 letras.

## 5. Cargar los datos del Excel

1. En Supabase, abre **SQL Editor › New query**.
2. Pega el contenido de `2_mis_datos_PRIVADO.sql` y toca **Run**. Al final verás cuántos registros se cargaron (245 movimientos, entre otros).
3. En la app, toca **Ya los cargué, volver a leer**.

## 6. Ponerla en la pantalla de inicio

1. En Safari, toca el botón **Compartir**.
2. Toca **Agregar a pantalla de inicio**.
3. Desde ahí se abre a pantalla completa, como cualquier otra app.

## 7. Rebe

1. Rebe abre la misma dirección en Safari en su iPhone.
2. Toca **Crear cuenta** y pone su correo y una contraseña.
3. En "¿Ya lo creó tu pareja?" escribe el código y toca **Unirme con el código**. El código está en **Ajustes › Su hogar** de la app de Rafa.
4. También la agrega a su pantalla de inicio (paso 6).

## Cómo funciona

- Lo que captura cualquiera de los dos aparece en el otro teléfono en segundos.
- Sin señal, la app abre con lo último que vio y guarda los cambios en el teléfono. Los sube sola cuando vuelve la conexión.
- Supabase puede pausar un proyecto gratis que nadie abre en varios días. Si pasa, se reactiva desde el panel de Supabase.

## Para publicar una nueva versión

1. Sube los archivos nuevos al repositorio.
2. En `sw.js`, cambia `VERSION` (por ejemplo, de `gastos-v1` a `gastos-v2`). Así los teléfonos descargan la nueva versión.
