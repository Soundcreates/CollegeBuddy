export interface GmailMessage {
    id: string;
    threadId: string;
    subject: string;
    from: string;
    to: string;
    date: string;
    student: string;
    snippet?: string;
    body?: string;
}