using Plots

function plotting_testcase1()

    x1 = ["DataFlowTasks"] ; x2 = ["Dagger"] 
    y1 = [6] ; y2 = [103]
    bar(
        x1, y1,
        title = "Overhead for creating 400 (independent) tasks",
        ylabel = "Overhead (ms)",
        legend=:none,
        color=:purple
    )
    bar!(
        x2, y2
    )

end
plotting_testcase1()
savefig("./fig/overhead/testcase1.png")


function plotting_testcase2()
    x1 = ["DataFlowTasks"] ; x2 = ["Dagger"] ; x3 = ["Base"]
    y1 = [6.232] ; y2 = [192] ; y3 = [0.003]
    bar(
        x1, y1,
        title = "Overhead for creating 400 tasks (with dependancies)",
        ylabel = "Overhead (ms)",
        legend=:none,
        color=:purple
    )
    bar!(
        x2, y2
    )
    bar!(
        x3, y3
    )
end
plotting_testcase2()
savefig("./fig/overhead/testcase2.png")