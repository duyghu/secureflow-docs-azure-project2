package com.secureflow.docs.service;

import com.secureflow.docs.model.DocumentRecord;
import com.secureflow.docs.repository.DocumentRepository;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DemoDataInitializer implements CommandLineRunner {

  private static final String LEGACY_DEMO_EMAIL = "duyghu@company.com";
  private static final String DEMO_EMAIL = "automission@company.com";

  private final DocumentRepository repository;

  public DemoDataInitializer(DocumentRepository repository) {
    this.repository = repository;
  }

  @Override
  public void run(String... args) {
    migrateLegacyDemoRecords();
    seedDemoRecordsWhenEmpty();
  }

  private void migrateLegacyDemoRecords() {
    List<DocumentRecord> changed = new ArrayList<>();
    for (DocumentRecord document : repository.findAll()) {
      boolean updated = false;
      if (LEGACY_DEMO_EMAIL.equalsIgnoreCase(document.getOwner())) {
        document.setOwner(DEMO_EMAIL);
        updated = true;
      }
      if (LEGACY_DEMO_EMAIL.equalsIgnoreCase(document.getOwnerUsername())) {
        document.setOwnerUsername(DEMO_EMAIL);
        updated = true;
      }
      if (LEGACY_DEMO_EMAIL.equalsIgnoreCase(document.getSignerEmail())) {
        document.setSignerEmail(DEMO_EMAIL);
        updated = true;
      }
      if (updated) {
        changed.add(document);
      }
    }
    if (!changed.isEmpty()) {
      repository.saveAll(changed);
    }
  }

  private void seedDemoRecordsWhenEmpty() {
    if (!repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL).isEmpty()) {
      return;
    }

    repository.saveAll(List.of(
        demoRecord(
            "Vendor Data Processing Addendum",
            "Contract",
            "Signature requested",
            "legal.ops@company.com",
            DEMO_EMAIL,
            "Ready for my signature",
            "Due today",
            "vendor-dpa.pdf",
            482304L,
            "Legal prepared this envelope for controlled signature with evidence capture."),
        demoRecord(
            "Regional Procurement Approval",
            "Invoice",
            "Signature requested",
            DEMO_EMAIL,
            "finance.approver@company.com",
            "Awaiting counterparty signature",
            "Due this week",
            "procurement-approval.pdf",
            140992L,
            "Finance review packet sent with spend owner and signer metadata."),
        demoRecord(
            "Employee Policy Attestation",
            "Policy",
            "Completed",
            "people.ops@company.com",
            DEMO_EMAIL,
            "Signed and archived",
            "Completed",
            "policy-attestation.pdf",
            90112L,
            "Policy acknowledgement completed and retained for audit.")));
  }

  private DocumentRecord demoRecord(
      String title,
      String category,
      String status,
      String ownerUsername,
      String signerEmail,
      String signatureStatus,
      String signatureDeadline,
      String originalFileName,
      Long fileSize,
      String extractedSummary) {
    DocumentRecord document = new DocumentRecord();
    document.setTitle(title);
    document.setCategory(category);
    document.setStatus(status);
    document.setOwner(ownerUsername);
    document.setOwnerUsername(ownerUsername);
    document.setSignerEmail(signerEmail);
    document.setSignatureStatus(signatureStatus);
    document.setSignatureDeadline(signatureDeadline);
    document.setOriginalFileName(originalFileName);
    document.setContentType("application/pdf");
    document.setFileSize(fileSize);
    document.setExtractedSummary(extractedSummary);
    document.setCreatedAt(Instant.now());
    return document;
  }
}
