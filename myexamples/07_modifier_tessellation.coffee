container = null
camera = null
scene = null
renderer = null
mesh = null
controls = null
uniforms = null

init = ()->

  container = document.getElementById 'container'
  camera = new THREE.PerspectiveCamera( 25, window.innerWidth/window.innerHeight, 1, 10000 )
  camera.position.z = 350

  scene = new THREE.Scene()

  attributes =
    displacement:
      type: 'v3'
      value: []
    customColor:
      type: 'c'
      value: []

  uniforms =
    amplitude:
      type: "f"
      value: 0.0

  shaderMaterial = new THREE.ShaderMaterial {
    uniforms: uniforms
    attributes: attributes
    shading: THREE.FlatShading
    side: THREE.DoubleSide
    vertexShader: '''
      uniform float amplitude;
      attribute vec3 customColor;
      attribute vec3 displacement;
      varying vec3 vNormal;
      varying vec3 vColor;
      void main() {
        vNormal = normal;
        vColor = customColor;
        vec3 newPosition = position + amplitude * displacement;
        gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );
      }
    '''
    fragmentShader: '''
      varying vec3 vNormal;
      varying vec3 vColor;
      void main() {
        const float ambient = 0.005;
        vec3 light = vec3( 1.0 );
        light = normalize( light );
        float directional = max( dot( vNormal, light ), 0.0 );
        gl_FragColor = vec4( ( directional + ambient ) * vColor, 1.0 );
        gl_FragColor.xyz = sqrt( gl_FragColor.xyz );
      }
    '''
  }

  ###
  geometry = new THREE.TextGeometry( "THREE.JS", {
    size: 40
    height: 5
    curveSegments: 3
    font: "helvetiker"
    weight: "bold"
    style: "normal"
    bevelThickness: 2
    bevelSize: 1
    bevelEnabled: true
  })
  ###
  geometry = new THREE.BoxGeometry( 40, 40, 40 )
  geometry.dynamic = true
  geometry.center()

  tessellateModifier = new THREE.TessellateModifier( 8 )
  tessellateModifier.modify geometry for i in [0...6]

  explodeModifier = new THREE.ExplodeModifier()
  explodeModifier.modify geometry

  vertices = geometry.vertices
  colors = attributes.customColor.value
  displacement = attributes.displacement.value

  v = 0
  for f in [0...geometry.faces.length]
    face = geometry.faces[ f ]
    nv = if face instanceof THREE.Face3 then 3 else 4

    h = 0.15 * Math.random()
    s = 0.5 + 0.5 * Math.random()
    l = 0.5 + 0.5 * Math.random()

    d = 10 * ( 0.5 - Math.random() )

    x = 2 * ( 0.5 - Math.random() )
    y = 2 * ( 0.5 - Math.random() )
    z = 2 * ( 0.5 - Math.random() )

    for i in [0...nv]
      colors[ v ] = new THREE.Color()
      displacement[ v ] = new THREE.Vector3()
      colors[ v ].setHSL( h, s, l )
      colors[ v ].convertGammaToLinear()
      displacement[ v ].set( x, y, z )
      v += 1

  console.log "faces", geometry.faces.length

  mesh = new THREE.Mesh( geometry, shaderMaterial )
  mesh.rotation.set( 0.5, 0.5, 0 )
  scene.add( mesh )

  renderer = new THREE.WebGLRenderer( { antialias: true } )
  renderer.setClearColor( 0x050505 )
  renderer.setPixelRatio( window.devicePixelRatio )
  renderer.setSize( window.innerWidth, window.innerHeight )

  container.appendChild( renderer.domElement )
  controls = new THREE.TrackballControls( camera )


animate = ()->
  requestAnimationFrame( animate )
  render()

render = ()->
  time = Date.now() * 0.001
  uniforms.amplitude.value = Math.sin( time * 0.5 )
  controls.update()
  renderer.render( scene, camera )

init()
animate()
#render()
