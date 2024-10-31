from numpy.distutils.core import setup, Extension
import get_docstring
import glob
import pickle


def build(setup_kwargs):
  # Generate documentation dictionary and save it in "pyslalib/"
  docstring = get_docstring.get_docstring()
  f = open("pyslalib/docstring_pickle.pkl", "wb")
  pickle.dump(docstring, f)
  f.close()

  ext = Extension(
    name = "pyslalib.slalib",
    include_dirs = ["."],
    sources = ["slalib.pyf"] + list(set(glob.glob("*.f")) - set(glob.glob("*-f2pywrappers.f"))) + glob.glob("*.F")
  )

  setup_kwargs.update({
    "ext_modules": [ext],
  })
