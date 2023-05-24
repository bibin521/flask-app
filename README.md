---
- name: "creating docker image"
  hosts: build
  become: true
  vars:
    user: "ec2-user"
    image_name: bibin521/flask
    hub_username: bibin521
    hub_password: Chalisons@123
    repo_url: https://github.com/bibin521/flask-app.git
    container_name: flask_app
  tasks:

    - name: "installing docker"
      yum:
        name:
          - docker
          - git
          - python2-pip
        state: present

    - name: "installing docker client for python"
      pip:
        name: docker-py
        state: present

    - name: "install flask module"
      pip:
        name: flask
        state: present

    - name: "restarting services"
      service:
        name: docker
        state: started
        enabled: yes

    - name: "add user to docker group"
      user:
        name: "{{user}}"
        groups: docker
        append: yes

    - name: "change file permission of var/run/docker.sock"
      file:
        path: "/var/run/docker.sock"
        mode: "777"

    - name: "clone flask application"
      git:
        repo: "{{ repo_url }}"
        dest: /var/flask
      register: git_status

    - debug:
        var: git_status
        

    - name: "login to dockerhub"
      docker_login:
        username: "{{ hub_username }}"
        password: "{{ hub_password }}"
     
    - name: "deleting container if any changes come in git"
      when: git_status.changed
      docker_container:
        name: "{{ container_name }}"
        state: absent

    - name: "deleting docker image if any changes come in git"
      when: git_status.changed
      docker_image:
        name: "{{ image_name }}"
        tag: "{{ item }}"
        state: absent
      with_items:
        - v1
        - latest

    - name: "build docker image"
      when: git_status.changed
      docker_image:
        name: "{{image_name}}"
        tag: "{{ item  }}"
        push: yes
        build:
          path: /var/flask        
      with_items:
        - v1
        - latest
        
    - name: "creating docker container"
      docker_container:
        name: "{{ container_name }}"
        image: bibin521/flask:latest
        ports:
          - "80:5000"

