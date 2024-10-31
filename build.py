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
    sources = list(set(["slalib.pyf"]) & set(glob.glob("*.f")) & set(glob.glob("*.F")) - set(glob.glob("*-f2pywrappers.f")))
  )

  setup_kwargs.update({
    "ext_modules": [ext],
  })
