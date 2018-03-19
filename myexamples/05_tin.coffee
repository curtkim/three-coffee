container = null
camera = null
scene = null
renderer = null
mesh = null
controls = null

init = ()->

  container = document.getElementById 'container'
  camera = new THREE.PerspectiveCamera( 27, window.innerWidth / window.innerHeight, 1, 3500 )
  camera.position.z = 5

  scene = new THREE.Scene()
  scene.fog = new THREE.Fog( 0x050505, 2000, 3500 ) # 왜 필요한거지?

  scene.add( new THREE.AmbientLight( 0x444444 ) )
  light1 = new THREE.DirectionalLight( 0xffffff, 0.5 )
  light1.position.set( 1, 1, 1 )
  scene.add( light1 )



  geometry = new THREE.BufferGeometry()

  indices = new Uint16Array( 3 * 8 )
  positions = new Float32Array( 3 * 9 )
  normals = new Float32Array( 3 * 9 )
  colors = new Float32Array( 3 * 9 )

  idx = 0
  for y in [-1..1]
    for x in [-1..1]
      positions[idx++] = x
      positions[idx++] = y
      positions[idx++] = 0
  positions[3*4] = 0
  positions[3*4+1] = 0
  positions[3*4+2] = 1

  idx = 0
  for y in [-1..1]
    for x in [-1..1]
      normals[idx++] = 0
      normals[idx++] = 0
      normals[idx++] = 1

  idx = 0
  for y in [-1..1]
    for x in [-1..1]
      colors[idx++] = 0
      colors[idx++] = 1
      colors[idx++] = 0
  colors[3*4] = 1
  colors[3*4+1] = 0
  colors[3*4+2] = 0

  idx = 0
  indices[idx++] = 0
  indices[idx++] = 1
  indices[idx++] = 4

  indices[idx++] = 0
  indices[idx++] = 4
  indices[idx++] = 3

  indices[idx++] = 3
  indices[idx++] = 4
  indices[idx++] = 7

  indices[idx++] = 3
  indices[idx++] = 7
  indices[idx++] = 6

  indices[idx++] = 1
  indices[idx++] = 2
  indices[idx++] = 5

  indices[idx++] = 1
  indices[idx++] = 5
  indices[idx++] = 4

  indices[idx++] = 4
  indices[idx++] = 5
  indices[idx++] = 8

  indices[idx++] = 4
  indices[idx++] = 8
  indices[idx++] = 7


  geometry.addAttribute 'index',    new THREE.BufferAttribute( indices, 1 )
  geometry.addAttribute 'position', new THREE.BufferAttribute( positions, 3 )
  geometry.addAttribute 'normal',   new THREE.BufferAttribute( normals, 3 )
  geometry.addAttribute 'color',    new THREE.BufferAttribute( colors, 3 )

  geometry.computeBoundingSphere()

  mesh = new THREE.Mesh( geometry, new THREE.MeshPhongMaterial {
    color: 0xaaaaaa
    ambient: 0xaaaaaa
    specular: 0xffffff
    shininess: 250
    side: THREE.DoubleSide
    vertexColors: THREE.VertexColors
  })
  scene.add( mesh )


  renderer = new THREE.WebGLRenderer( { antialias: false } )
  renderer.setClearColor( scene.fog.color )
  renderer.setPixelRatio( window.devicePixelRatio )
  renderer.setSize( window.innerWidth, window.innerHeight )

  #renderer.gammaInput = true
  #renderer.gammaOutput = true

  container.appendChild( renderer.domElement )
  controls = new THREE.TrackballControls(camera)

animate = ()->
  requestAnimationFrame( animate )
  render()

render = ()->
  time = Date.now() * 0.001
  controls.update()
  #mesh.rotation.x = time * 0.25
  #mesh.rotation.y = time * 0.5
  renderer.render( scene, camera )

init()
animate()
#render()
