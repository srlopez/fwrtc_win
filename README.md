# IKUZAIN 4.0

## [IKUZAIN 4.0](https://tknika.eus/cont/proyecto-de-viceconsejeria/ikuzain-asistente-sanitario-digital-4-0)

El proyecto “IKUZAIN Asistente Sanitario Digital 4.0.” trata de diseñar un dispositivo médico que permita a los Técnicos de Emergencias Sanitarias, de Auxiliar de Enfermería y  de Atención a Personas en Situación de Dependencia presentes junto al paciente en el lugar de la emergencia, en el domicilio o en la institución, ponerse en contacto con el profesional sanitaria situado en el Centro Coordinador de Emergencias (112), en centro de salud o en el centro hospitalario. Dicho contacto se realizará de forma directa y segura mediante los diferentes aplicativos que permitan emitir y recibir la escena de asistencia al centro de diagnóstico. 
Esto permitirá que la asistencia sanitaria y sociosanitaria que imparten los técnicos sea más completa.

## PARTICIPANTES

- Kepa García Cabezudo, de [Ambulancias Gipuzkoa S COOP](https://ambulanciasgipuzkoa.eus/), y
- Joseba Illarramendi Rezabal, del Centro gerontológico [San Juan Egoitza](https://miresi.es/gipuzkoa/zumaia/residencia-san-juan-zumaia/),  en Asesoramiento, colaboración y validación de los productos  
- Ane de la Arada, de [CIFP EASO POLITEKNIKOA](https://easo.hezkuntza.net/es/inicio), y 
- Viky Escudero Muñoz, de  [CIFP EASO POLITEKNIKOA](https://easo.hezkuntza.net/es/inicio) como dirección de proyecto, y
- Santiago López, de [IES PLAIAUNDI](http://www.plaiaundi.hezkuntza.net/), como técnico.

## ARQUITECTURA 

El proyecto consta de varias partes, quizás la más visible es el aplicativo en móvil Android, pero también consta de un aplicativo en Windows, de un servicio concentrador de comunicaciones y de un servidor [STUN](https://www.3cx.es/voip-sip/servidor-stun/) para comunicación RT.

### Aplicativos
- [Android](https://github.com/srlopez/fwrtc.git)

    Desarrollado en [Flutter](https://flutter.dev/) con [WebRTC](https://webrtc.org/) como librería de gestión de protocolos de tiempo real.
- [Windows](https://github.com/srlopez/fwrtc_win.git)

    Desarrollado en [Flutter](https://flutter.dev/) con [WebRTC](https://webrtc.org/) como librería de gestión de protocolos de tiempo real.
- [Hub](https://github.com/srlopez/hub-fwrtc.git)

    Servicio desarrollado en [node.js](https://nodejs.org/es/), instalado como servicio en el Politécnico EASO.

La [pila de protocolos](https://fr.wikipedia.org/wiki/WebRTC) utilizados  la representa esta imagen:

 <img src="https://upload.wikimedia.org/wikipedia/commons/9/97/Webrtc_triangle_architecture.svg" width="60%" height="60%">
