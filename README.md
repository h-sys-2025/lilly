<div align="center">
  <img src="https://github.com/user-attachments/assets/1948c77f-81cd-4d4b-a6a3-0c36b6936fa1" width="445.4" alt="Lilly">

</div>

<img width="1381" height="822" alt="screenshot-2026-04-01_12-24-33" src="https://github.com/user-attachments/assets/047e5ea4-0062-499f-9026-29f98a47f4a3" />


An editor designed as a batteries included experience, eliminating the need for plugins. So, basically Helix but for VIM
motions. The end vision is a one to one replacement/equivalent functionality for all VIM features, macros, motions, and more.

## How to build (requires the V compiler https://vlang.io)

```v
v install
# v install asks for passwd (IDK WHY), so just run this:
v install <dependency-url>
# v install, installs:
# https://git.catkin.dev/tauraamui/tauraamui.bobatea # by default, is broken. (you need to comment some code in bobatea/key.v)
# https://git.catkin.dev/tauraamui/kdlv # works fine for most cases.

# ./make.vsh build # does not work,
# try this instead:
v .
# this build entire project in ./ dir, all files. this wcompiles fine, otherwise there are MANY issues.
```
You can see what other tasks are available to run with `./make.vsh --tasks`

(you can compile make.vsh into a binary to make executing tasks as fast as possible, use `./make.vsh compile-make` or `v -prod -skip-running make.vsh`)

### Not convinced?

- Just use emacs!