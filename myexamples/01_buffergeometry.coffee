container = null
camera = null
scene = null
renderer = null
mesh = null

init = ()->

  container = document.getElementById 'container'
  camera = new THREE.PerspectiveCamera( 27, window.innerWidth / window.innerHeight, 1, 3500 )
  camera.position.z = 2750

  scene = new THREE.Scene()
  scene.fog = new THREE.Fog( 0x050505, 2000, 3500 ) # 왜 필요한거지?

  scene.add( new THREE.AmbientLight( 0x444444 ) )
  light1 = new THREE.DirectionalLight( 0xffffff, 0.5 )
  light1.position.set( 1, 1, 1 )
  scene.add( light1 )

  light2 = new THREE.DirectionalLight( 0xffffff, 1.5 )
  light2.position.set( 0, -1, 0 )
  scene.add( light2 )


  triangles = 160000
  geometry = new THREE.BufferGeometry()

  # break geometry into
  # chunks of 21,845 triangles (3 unique vertices per triangle)
  # for indices to fit into 16 bit integer number
  # floor(2^16 / 3) = 21845

  chunkSize = 21845
  indices = new Uint16Array( triangles * 3 )

  for i in [0...indices.length]
    indices[i] = i % ( 3 * chunkSize )

  positions = new Float32Array( triangles * 3 * 3 )
  normals = new Float32Array( triangles * 3 * 3 )
  colors = new Float32Array( triangles * 3 * 3 )

  color = new THREE.Color()

  n = 800
  n2 = n/2  # triangles spread in the cube
  d = 32
  d2 = d/2  # individual triangle size

  pA = new THREE.Vector3()
  pB = new THREE.Vector3()
  pC = new THREE.Vector3()
  cb = new THREE.Vector3()
  ab = new THREE.Vector3()

  for i in [0...positions.length] by 9
    x = Math.random() * n - n2
    y = Math.random() * n - n2
    z = Math.random() * n - n2

    ax = x + Math.random() * d - d2
    ay = y + Math.random() * d - d2
    az = z + Math.random() * d - d2

    bx = x + Math.random() * d - d2
    By = y + Math.random() * d - d2
    bz = z + Math.random() * d - d2

    cx = x + Math.random() * d - d2
    cy = y + Math.random() * d - d2
    cz = z + Math.random() * d - d2

    positions[ i ]     = ax
    positions[ i + 1 ] = ay
    positions[ i + 2 ] = az

    positions[ i + 3 ] = bx
    positions[ i + 4 ] = By
    positions[ i + 5 ] = bz

    positions[ i + 6 ] = cx
    positions[ i + 7 ] = cy
    positions[ i + 8 ] = cz

    # flat face normals

    pA.set( ax, ay, az )
    pB.set( bx, By, bz )
    pC.set( cx, cy, cz )

    cb.subVectors( pC, pB )
    ab.subVectors( pA, pB )
    cb.cross( ab )

    cb.normalize()

    nx = cb.x
    ny = cb.y
    nz = cb.z

    normals[ i ]     = nx
    normals[ i + 1 ] = ny
    normals[ i + 2 ] = nz

    normals[ i + 3 ] = nx
    normals[ i + 4 ] = ny
    normals[ i + 5 ] = nz

    normals[ i + 6 ] = nx
    normals[ i + 7 ] = ny
    normals[ i + 8 ] = nz

    # colors

    vx = ( x / n ) + 0.5
    vy = ( y / n ) + 0.5
    vz = ( z / n ) + 0.5

    color.setRGB( vx, vy, vz )

    colors[ i ]     = color.r
    colors[ i + 1 ] = color.g
    colors[ i + 2 ] = color.b

    colors[ i + 3 ] = color.r
    colors[ i + 4 ] = color.g
    colors[ i + 5 ] = color.b

    colors[ i + 6 ] = color.r
    colors[ i + 7 ] = color.g
    colors[ i + 8 ] = color.b


  geometry.addAttribute 'index',    new THREE.BufferAttribute( indices, 1 )
  geometry.addAttribute 'position', new THREE.BufferAttribute( positions, 3 )
  geometry.addAttribute 'normal',   new THREE.BufferAttribute( normals, 3 )
  geometry.addAttribute 'color',    new THREE.BufferAttribute( colors, 3 )

  ### ???
  offsets = triangles / chunkSize

  for i in [0...offsets]
    offset =
      start: i * chunkSize * 3
      index: i * chunkSize * 3
      count: Math.min( triangles - ( i * chunkSize ), chunkSize ) * 3
    geometry.offsets.push offset
  ###
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


animate = ()->
  requestAnimationFrame( animate )
  render()

render = ()->
  time = Date.now() * 0.001
  #mesh.rotation.x = time * 0.25
  #mesh.rotation.y = time * 0.5
  renderer.render( scene, camera )

init()
#animate()
render()
