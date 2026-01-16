To start the jupyter server run 
```bash
nix develop .#<option>
```
The options are:
- `minimal`: This is a barebone jupyter server that only contains python, the server itself, an LSP and Vim bindings for the server. 
- `default`: This includes the server above an some physics packages such as `numpy`, `matplotlib`, `scipy`, `pandas` and `astropy`
- `root`: Contains all the packages mentioned above and the CERN ROOT package.
