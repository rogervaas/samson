# frozen_string_literal: true
prod_env = Environment.create!(
  name: 'Production',
  production: true
)
Environment.create!(name: 'Staging')
Environment.create!(name: 'Master')

prod = DeployGroup.create!(
  name: 'Production',
  environment: prod_env
)

project = Project.create!(
  name: "Example-project",
  repository_url: "https://github.com/samson-test-org/example-project.git"
)

project.stages.create!(
  name: "Production",
  deploy_groups: [prod]
)

user = User.create!(
  name: "Mr. Seed",
  email: "seed@example.com",
  external_id: "123"
)

project.releases.create!(
  commit: "1234" * 10,
  author: user
)
