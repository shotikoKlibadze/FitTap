# Dive into Core AI model authoring and optimization
# WWDC26 session 325 · https://developer.apple.com/videos/play/wwdc2026/325/
# Apple's sample code as published on the session page, one block per snippet, in video order.
# Explanations: ../README.md

# MARK: - [3:27] Define and export a PyTorch model

import torch
import torch.nn as nn

# Define a simple model
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(256, 512)
        self.fc2 = nn.Linear(512, 10)

    def forward(self, x):
        return self.fc2(torch.relu(self.fc1(x)))

# Export with torch.export
model = MLP().eval()
example_input = (torch.randn(1, 256),)
exported_program = torch.export.export(model, example_input)

# MARK: - [4:02] Convert, optimize and run inference with Core AI

import coreai
import coreai_torch
from coreai.runtime import NDArray

# Convert to Core AI
converter = coreai_torch.TorchConverter()
converter.add_exported_program(
    exported_program,
    input_names=["features"], output_names=["logits"])
core_ai_program = converter.to_coreai()

# Optimize and save to .aimodel
core_ai_program.optimize()
asset = core_ai_program.save_asset("mlp.aimodel")

# Run inference
specialized_model = await AIModel.load("mlp.aimodel")
specialized_function = specialized_model.load_function("main")
result = await specialized_function({"features": NDArray(example[0].numpy())})

# MARK: - [21:12] Define a SiLU Metal kernel with PyTorch reference

import torch
from coreai_torch.dsl import TorchMetalKernel, MetalParameter

def silu_torch(x):
    return x * torch.sigmoid(x)

SILU_MSL = """
float val = float(x[gid]);
float sig = 1.0f / (1.0f + exp(-val));
y[gid] = TYPE(val * sig);
"""

silu_kernel = TorchMetalKernel(
    name="fused_silu",
    input_names=["x"],
    result_names=["y"],
    src=SILU_MSL,
    torch_defn=silu_torch,
    metal_params=[MetalParameter("gid", "uint", "thread_position_in_grid")],
    template_dtypes={"x": "TYPE"},
)

# MARK: - [22:09] Use a custom Metal kernel and convert with TorchConverter

class MyModel(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = torch.nn.Linear(256, 256)

    def forward(self, x):
        h = self.linear(x)
        n = h.numel()
        return silu_kernel(
            h,
            threads_per_grid_size=(n, 1, 1),
            threads_per_thread_group=(min(n, 256), 1, 1),
            result_shapes=[h.shape],
        )

exported_program = torch.export.export(MyModel(), (torch.randn(1, 256),))

converter = coreai_torch.TorchConverter()
converter.register_custom_kernels([silu_kernel])
converter.add_exported_program(exported_program,
                               input_names=["x"], output_names=["y"])
deployable = converter.to_coreai()  # MSL integrated into asset
