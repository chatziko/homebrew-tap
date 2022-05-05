class OrToolsAT81 < Formula
  desc "Google's Operations Research tools"
  homepage "https://developers.google.com/optimization/"
  url "https://github.com/google/or-tools/releases/download/v8.1/or-tools_MacOsX-10.15.7_v8.1.8487.tar.gz"
  sha256 "cdf5d5c4dd10ddfa39eb951e6b8122b2a48c7d1dbd87bb5f792a7596aea8b8bb"

  def install
    include.install Dir["include/*"]
    lib.install Dir["lib/*"]
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include "ortools/linear_solver/linear_solver.h"

      namespace operations_research {
      void LinearProgrammingExample() {
        MPSolver solver("LinearExample", MPSolver::GLOP_LINEAR_PROGRAMMING);

        const double infinity = solver.infinity();
        // x and y are non-negative variables.
        MPVariable* const x = solver.MakeNumVar(0.0, infinity, "x");
        MPVariable* const y = solver.MakeNumVar(0.0, infinity, "y");
        LOG(INFO) << "Number of variables = " << solver.NumVariables();

        // x + 2*y <= 14.
        MPConstraint* const c0 = solver.MakeRowConstraint(-infinity, 14.0);
        c0->SetCoefficient(x, 1);
        c0->SetCoefficient(y, 2);

        // 3*x - y >= 0.
        MPConstraint* const c1 = solver.MakeRowConstraint(0.0, infinity);
        c1->SetCoefficient(x, 3);
        c1->SetCoefficient(y, -1);

        // x - y <= 2.
        MPConstraint* const c2 = solver.MakeRowConstraint(-infinity, 2.0);
        c2->SetCoefficient(x, 1);
        c2->SetCoefficient(y, -1);
        LOG(INFO) << "Number of constraints = " << solver.NumConstraints();

        // Objective function: 3x + 4y.
        MPObjective* const objective = solver.MutableObjective();
        objective->SetCoefficient(x, 3);
        objective->SetCoefficient(y, 4);
        objective->SetMaximization();

        const MPSolver::ResultStatus result_status = solver.Solve();
        // Check that the problem has an optimal solution.
        if (result_status != MPSolver::OPTIMAL) {
          LOG(FATAL) << "The problem does not have an optimal solution!";
        }

        LOG(INFO) << "Solution:";
        LOG(INFO) << "Optimal objective value = " << objective->Value();
        LOG(INFO) << x->name() << " = " << x->solution_value();
        LOG(INFO) << y->name() << " = " << y->solution_value();
      }
      }  // namespace operations_research

      int main(int argc, char** argv) {
        operations_research::LinearProgrammingExample();
        return EXIT_SUCCESS;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-DUSE_GLOP", "-I#{include}", "-L#{lib}", "-lortools", "-lglog", "-o", "test"
    system "./test"
  end
end
