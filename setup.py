from skbuild import setup
setup(
    name="musix",
    version="0.1.0",
    packages=["musix"],
    package_dir={"": "python"},
    cmake_install_dir="python/musix",
    cmake_args=["-DPYTHON_MODULE=ON", "-DMACOSX_DEPLOYMENT_TARGET=10.15"],
    package_data={"musix": ["py.typed", "*.pyi", "**/*.pyi", "*/*/*.pyi"]},
    zip_safe=False,
)
