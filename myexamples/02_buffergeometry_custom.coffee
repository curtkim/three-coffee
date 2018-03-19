container = null
camera = null
scene = null
renderer = null

particleSystem = null
uniforms = null
geometry = null

particles = 100000

WIDTH = window.innerWidth
HEIGHT = window.innerHeight


init = ()->
  camera = new THREE.PerspectiveCamera( 40, WIDTH / HEIGHT, 1, 10000 )
  camera.position.z = 300

  scene = new THREE.Scene()

  attributes =
    size:
      type: 'f'
      value: null
    customColor:
      type: 'c'
      value: null

  uniforms =
    color:
      type: "c"
      value: new THREE.Color( 0xffffff )
    texture:
      type: "t"
      value: THREE.ImageUtils.loadTexture( "../examples/textures/sprites/spark1.png" )

  # glsl reference
  # http://nehe.gamedev.net/article/glsl_an_introduction/25007/
  shaderMaterial = new THREE.ShaderMaterial {
    uniforms:       uniforms
    attributes:     attributes
    vertexShader:   '''
      attribute float size;
      attribute vec3 customColor;
      varying vec3 vColor;
      void main() {
        vColor = customColor;
        vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
        gl_PointSize = size * ( 200.0 / length( mvPosition.xyz ) );
        gl_Position = projectionMatrix * mvPosition;
      }
    '''
    fragmentShader: '''
      uniform vec3 color;
      uniform sampler2D texture;
      varying vec3 vColor;
      void main() {
        gl_FragColor = vec4( color * vColor, 1.0 );
        gl_FragColor = gl_FragColor * texture2D( texture, gl_PointCoord );
      }
    '''
    blending:       THREE.AdditiveBlending
    depthTest:      false
    transparent:    true
  }

  radius = 200
  geometry = new THREE.BufferGeometry()

  positions = new Float32Array( particles * 3 )
  values_color = new Float32Array( particles * 3 )
  values_size = new Float32Array( particles )

  color = new THREE.Color()

  for v in [0...particles]
    values_size[ v ] = 20
    positions[ v * 3 + 0 ] = ( Math.random() * 2 - 1 ) * radius
    positions[ v * 3 + 1 ] = ( Math.random() * 2 - 1 ) * radius
    positions[ v * 3 + 2 ] = ( Math.random() * 2 - 1 ) * radius
    color.setHSL( v / particles, 1.0, 0.5 )
    values_color[ v * 3 + 0 ] = color.r
    values_color[ v * 3 + 1 ] = color.g
    values_color[ v * 3 + 2 ] = color.b

  geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) )
  geometry.addAttribute( 'customColor', new THREE.BufferAttribute( values_color, 3 ) )
  geometry.addAttribute( 'size', new THREE.BufferAttribute( values_size, 1 ) )

  particleSystem = new THREE.PointCloud( geometry, shaderMaterial )

  scene.add( particleSystem )

  renderer = new THREE.WebGLRenderer()
  renderer.setPixelRatio( window.devicePixelRatio )
  renderer.setSize( WIDTH, HEIGHT )

  container = document.getElementById 'container'
  container.appendChild renderer.domElement


animate = ()->
  requestAnimationFrame( animate )
  render()

render = ()->
  time = Date.now() * 0.005
  particleSystem.rotation.z = 0.01 * time

  size = geometry.attributes.size.array

  for i in [0...particles]
    size[ i ] = 10 * ( 1 + Math.sin( 0.1 * i + time ) )
  geometry.attributes.size.needsUpdate = true
  renderer.render(scene, camera)

init()
animate()
