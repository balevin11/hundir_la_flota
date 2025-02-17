extends Control
var nombre : String
var contrasena : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Función que se ejecuta cuando el botón es presionado
func _on_button_pressed() -> void:
	# Obtener el texto de los LineEdit
	nombre = $"../Nombre/LineEdit".text
	contrasena = $"../Contrasena/LineEdit".text
	
	print("Nombre: ", nombre, " Contraseña: ", contrasena)
	
	# Comprobar si el nombre y la contraseña no están vacíos
	if nombre==null or nombre == "" or contrasena==null or contrasena == "":
		$"../completar campos".visible = true
		await Wait(2)
		$"../completar campos".visible = false
		return
	
	# Llamar a la función para registrar el usuario en el servidor
	print("funcion registrar")
	registrar_usuario(nombre, contrasena)

# Función para registrar el usuario en el servidor
func registrar_usuario(username: String, password: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_server_has_responded)
	var body = JSON.stringify({"username": username, "contrasena": password})
	var headers = []
	http_request.request("http://127.0.0.1:8000/api/1/users", headers, HTTPClient.METHOD_POST, body)
	
	
func _on_server_has_responded(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	print("Server response:")
	print(response)
	if response_code == 201:
		$"../creado".visible = true
		await Wait(2)
		$"../creado".visible = false
	elif response_code == 409:
		$"../usuario existente".visible = true
		await Wait(2)
		$"../usuario existente".visible = false

func Wait(WaitTime):
	await get_tree().create_timer(WaitTime).timeout
