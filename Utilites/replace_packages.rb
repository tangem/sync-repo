#!/usr/bin/env ruby

require 'xcodeproj'
require 'set'

project_path = 'TangemApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)


local_refs = []

# project.root_object.package_references.each do |ref|
#   # vendor/ios_dependencies/blockiesswift - relative_path
#   # XCRemoteSwiftPackageReference
#   # XCLocalSwiftPackageReference
#   next unless ref.instance_of?(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
#   pkg_name = File.basename(ref.repositoryURL, ".git")
#   puts pkg_name
#   local_pkg = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
#   local_pkg.relative_path = "./vendor/ios_dependencies/#{pkg_name}"
#   local_refs << local_pkg
# end

# project.root_object.package_references.concat(local_refs)

project_local_refs_to_add = []

project.targets.each do |target|
  target_local_refs = []
  puts "*** #{target.name} ***"
  target.package_product_dependencies.each do |dep|
    ref = dep.package
    next unless ref.instance_of?(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
    puts dep.product_name
    pkg_name = File.basename(ref.repositoryURL, ".git")
    pkg = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
    pkg.relative_path = "./vendor/ios_dependencies/#{pkg_name}"
    project_local_refs_to_add << pkg
    local_ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    local_ref.package = pkg
    local_ref.product_name = dep.product_name
    target_local_refs << local_ref
    # project.root_object.package_references << pkg

    # pkg_name = File.basename(ref.repositoryURL, ".git")
    # puts pkg_name
    # local_pkg = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
    # local_pkg.relative_path = "vendor/ios_dependencies/#{pkg_name}"
    # target_local_refs << local_pkg

    puts "----"
  end

  # target.package_product_dependencies.each { |dep| puts "target_before: #{dep.package}" }

  #target.package_product_dependencies.delete_if { |dep| target_remote_refs_to_remove.include?(dep.package) }
  target.package_product_dependencies.concat(target_local_refs)

  # target.package_product_dependencies.each { |dep| puts "target_after: #{dep.package}" }

  # target.package_product_dependencies.clear# = target_local_refs
  # target.package_product_dependencies.concat(target_local_refs)
end

# project.root_object.package_references.each { |ref| puts "before: #{ref}" }




project_local_refs_to_add.uniq! { |ref| ref.relative_path }

project.root_object.package_references.concat(project_local_refs_to_add)

# project.root_object.package_references.each { |ref| puts "after: #{ref}" }


all_rem_pkg = project.objects.select { |obj| obj.instance_of?(Xcodeproj::Project::Object::XCSwiftPackageProductDependency) and obj.package.instance_of?(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference) }
puts "all_pkg: #{all_rem_pkg}"
all_rem_pkg.each { |obj| obj.remove_from_project }


all_rem = project.objects.select { |obj| obj.instance_of?(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference) }
puts "all_rem: #{all_rem}"
all_rem.each { |obj| obj.remove_from_project }



project.save

