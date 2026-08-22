# Contributing

## Learning workflow with production discipline

This repository is a learning project, but its change-management process mirrors
production work. Each completed checkpoint is a small, independently reviewable
change.

1. Create a focused branch from the current `main` branch.
2. Implement one coherent checkpoint and update relevant documentation.
3. Run the applicable formatting, validation, and tests.
4. Commit the checkpoint once with a clear Conventional Commit-style message.
5. Push the branch.
6. Open a pull request and review the implementation, documentation, validation
   results, and security impact before merging.

The project owner creates and merges pull requests. Automated changes must not
be committed or pushed directly to `main`.

## Pull request checklist

- [ ] The change has a clear, limited purpose.
- [ ] Documentation reflects the current state and next step.
- [ ] No secrets, state files, generated provider files, or local `.env` changes
      are included.
- [ ] Terraform is formatted and validated when Terraform changes are present.
- [ ] The PR description identifies the validation performed and any remaining
      prerequisites or risks.
