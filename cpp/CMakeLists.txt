cmake_minimum_required(VERSION 4.1.2)
project(hello-world VERSION 0.0.1)

add_executable(${PROJECT_NAME}
  main.cpp
)

install(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION bin
)
