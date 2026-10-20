class Libqif < Formula
  desc "Quantitative Information Flow C++ library"
  homepage "https://github.com/chatziko/libqif"
  head "https://github.com/chatziko/libqif.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "glpk"
  depends_on "gmp"
  depends_on "gsl"
  depends_on "or-tools"

  def install
    args = std_cmake_args + %W[
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    ]
    args << "-DMARCH=native" if Hardware::CPU.intel?   # local build, optimize for this cpu

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--target", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <qif>
      using namespace std;
      using namespace qif;

      int main() {
        cout << probab::is_proper(probab::uniform<double>(5)) << endl;

        // solve a small linear program with or-tools (GLOP)
        lp::LinearProgram<double> lp;
        lp.solver = lp::Solver::GLOP;
        auto x = lp.make_var(0, 1), y = lp.make_var(0, 1);
        lp.set_obj_coeff(x, 1);
        lp.set_obj_coeff(y, 1);
        lp.maximize = true;
        lp.solve();
        cout << lp.objective() << endl;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-I#{HOMEBREW_PREFIX}/include",
           "-L#{lib}", "-L#{HOMEBREW_PREFIX}/lib",
           "-lqif", "-larmadillo", "-lgmp", "-lmp++", "-lortools", "-o", "test"
    assert_equal "1\n2\n", shell_output("./test")
  end
end
