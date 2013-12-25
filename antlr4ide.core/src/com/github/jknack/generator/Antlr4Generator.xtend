/*
 * generated by Xtext
 */
package com.github.jknack.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.core.runtime.Path
import com.google.inject.Inject
import org.osgi.framework.Bundle
import org.eclipse.core.resources.IWorkspaceRoot
import com.github.jknack.event.ConsoleListener
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IResource

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class Antlr4Generator implements IGenerator {
  @Inject
  private Bundle bundle

  @Inject
  private ToolOptionsProvider optionsProvider

  @Inject
  private ConsoleListener console

  @Inject
  private IWorkspaceRoot workspaceRoot

  override void doGenerate(Resource resource, IFileSystemAccess fsa) {
    val file = workspaceRoot.getFile(new Path(resource.getURI().toPlatformString(true)))
    val project = file.project
    val config = optionsProvider.options(project)
    val monitor = new NullProgressMonitor()
    // call ANTLR
    new ToolRunner(bundle).run(file, config, console)

    project.refreshLocal(IResource.DEPTH_INFINITE, monitor)
    val output = config.output(project)
    if (project.exists(output.relative)) { 
      val folder = project.getFolder(output.relative)
      /**
       * Mark files as derived
       */
      folder.accept([ generated|
        generated.setDerived(config.derived, monitor)
        return true
      ])
    }
  }

//  private def commentText(IGrammarAccess access) {
//    val rules = GrammarUtil.allRules(access.grammar)
//    return rules
//        .filter[it.name.equals("ML_COMMENT") || it.name.equals("SL_COMMENT")]
//        .map[it.toString]
//        .join(" ")
//  }

}
