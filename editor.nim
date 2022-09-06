import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw], glm
import strutils

var 
  window_width = 1280f
  window_height = 720f

proc main() =
  assert glfwInit()
  
  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFW_DECORATED, GLFW_TRUE)

  var window: GLFWWindow = glfwCreateWindow(1280, 720, "Critic Engine")
  if window == nil:
    quit(-1)

  window.makeContextCurrent()

  assert glInit()


  proc drawTriangle()=
    glLoadIdentity()
    glPushMatrix()   

    glBegin(GL_TRIANGLES)
    glColor3f(1,0,0)
    glVertex2f(0,1)
    glColor3f(0,1,0)
    glVertex2f(1f,-1)
    glColor3f(0,0,1)
    glVertex2f(-1f,-1)
    glEnd()
    
    glPopMatrix()

  echo "OpenGL version: ", cast[cstring](glGetString(GL_VERSION))
  echo "OpenGL renderer: ", cast[cstring](glGetString(GL_RENDERER))

  let context = igCreateContext()

  assert igGlfwInitForOpenGL(window, true)
  assert igOpenGL3Init()

  igStyleColorsDark()
  var io = igGetIO()
  var kek: ImWchar16 = 10
  io.fonts.addFontFromFileTTF("arial.ttf", 20, nil, addr kek)
  
  
  # фреймбуфер
  var fbo: Gluint   
  glGenFramebuffers(1, addr fbo)
  glBindFramebuffer(GL_FRAMEBUFFER, fbo)

  glViewport(0, 0, 500, 500)
  glClearColor(0.1f, 0.1f, 0.1f, 1.0f)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT) # we're not using the stencil buffer now
  glEnable(GL_DEPTH_TEST)
  drawTriangle()

  if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE:
    echo "Error " & $(int)glCheckFramebufferStatus(GL_FRAMEBUFFER)   
 

  var texture: Gluint
  glGenTextures(1, addr texture)
  glBindTexture(GL_TEXTURE_2D, texture)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.GLint,  500, 500, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (GLint)GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (GLint)GL_LINEAR)
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0)

  while not window.windowShouldClose: 
    glBindFramebuffer(GL_FRAMEBUFFER, 0);  

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)    

    igOpenGL3NewFrame()
    igGlfwNewFrame()    

    igNewFrame()    
    
    igBeginMainMenuBar()
    igMenuItem("File")
    igMenuItem("About")
    igEndMainMenuBar()
    
    igSetNextWindowPos(ImVec2(x: 1, y: 26))
    igSetNextWindowSize(ImVec2(x: 1278, y: 34))
    igBegin("Panel bar", nil, NoTitleBar)
    igSetCursorPosX((windowWidth - 40f) * 0.5f);
    igSetCursorPosY(0)
    if igButton("► Play"):
      igText("test")
    igEnd()
    
    # Hierarchy
    igSetNextWindowSize(ImVec2(x: 300, y: 500))
    igSetNextWindowPos(ImVec2(x: 1, y: 60))
    igBegin("Hierarchy")  
    if igTreeNode("nilObject"):      
      igTreePop();
    if igTreeNode("Image"):      
      igTreePop();
    igEnd()
    

    # Окно игры
    igSetNextWindowSize(ImVec2(x: 640, y: 500))
    igSetNextWindowPos(ImVec2(x: 310, y: 60))
    igBegin("Viewport")  
    igImage(addr texture,  ImVec2(x: 500, y: 500))
    igEnd()

    # Inspector 
    igSetNextWindowSize(ImVec2(x: 319, y: 659))
    igSetNextWindowPos(ImVec2(x: 960, y: 60))
    igBegin("Inspector")  
    igText("Transform")
    igText("Script")   
    igEnd()

    # Project 
    igSetNextWindowSize(ImVec2(x: 950, y: 150))
    igSetNextWindowPos(ImVec2(x: 1, y: 570))
    igBegin("Project")  
    if igCollapsingHeader("Assets"):
      igText("game.nimble")  
      if igTreeNode("src"):
        igText("main.nim")      
        igTreePop();
    igEnd()
    
    igRender()
    igOpenGL3RenderDrawData(igGetDrawData()) 
    
    window.swapBuffers()
    
    glfwPollEvents()

  glDeleteFramebuffers(1, addr fbo) 
  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  window.destroyWindow()
  glfwTerminate()

main()